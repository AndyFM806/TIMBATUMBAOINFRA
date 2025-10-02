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

###############################
# 4) data "archive_file"
#    - Empaqueta tu JAR en un ZIP para subirlo a Lambda
###############################
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/target/inscripciones.jar"  # <- compila tu JAR con Maven/Gradle
  output_path = "${path.module}/lambda_function_payload.zip"
}

###############################
# 5) aws_lambda_function
###############################
resource "aws_lambda_function" "inscripciones" {
  function_name = var.lambda_function_name
  runtime       = "java17"
  handler       = var.lambda_handler             # p.ej. com.academia.HelloLambda::handleRequest
  role          = aws_iam_role.lambda_exec.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # (Opcional) Variables de entorno
  environment {
    variables = {
      DDB_TABLE = var.ddb_table_name
      STAGE     = var.stage
    }
  }

  timeout = 15
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