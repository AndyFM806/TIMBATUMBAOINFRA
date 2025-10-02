###############################
# 1) aws_iam_role
###############################
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-inscripciones-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

###############################
# 2) aws_iam_policy (permisos extra opcionales)
#    - Ejemplo: PutItem/GetItem en DynamoDB (tabla inscripciones)
###############################
resource "aws_iam_policy" "lambda_extra_policy" {
  name        = "lambda-inscripciones-extra-policy"
  description = "Permisos extra para la Lambda de inscripciones (ej. DynamoDB)"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # (Opcional) Permisos a DynamoDB
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.ddb_table_name}"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

###############################
# 3) aws_iam_role_policy_attachment
#    - Logs básicos a CloudWatch + política extra
###############################
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "extra_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_extra_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../java/target/inscripciones.jar"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "inscripciones" {
  function_name    = "inscripciones"
  runtime          = "java17"
  handler          = "com.academia.HelloLambda::handleRequest"
  role             = aws_iam_role.lambda_exec.arn

  filename         = "${path.module}/java/target/inscripciones.jar"
  source_code_hash = filebase64sha256("${path.module}/java/target/inscripciones.jar")

  timeout     = 15
  memory_size = 512
}


###############################
# Variables útiles
###############################
variable "aws_region" {
  description = "Región AWS donde despliegas"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
  default     = "inscripciones"
}

variable "lambda_handler" {
  description = "Handler Java de la Lambda"
  type        = string
  default     = "com.academia.HelloLambda::handleRequest"
}

variable "ddb_table_name" {
  description = "Nombre de la tabla DynamoDB (si aplica)"
  type        = string
  default     = "inscripciones"
}

variable "stage" {
  description = "Entorno (Dev/QA/Prod)"
  type        = string
  default     = "Dev"
}

###############################
# Outputs
###############################
output "lambda_name" {
  value = aws_lambda_function.inscripciones.function_name
}
output "lambda_arn" {
  value = aws_lambda_function.inscripciones.arn
}