
# IAM ROLE para la Lambda

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


# (Opcional) Política extra: DynamoDB

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "lambda_extra_policy" {
  name        = "lambda-inscripciones-extra-policy"
  description = "Permisos extra (DynamoDB) para Lambda inscripciones"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem","dynamodb:GetItem","dynamodb:UpdateItem"],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.ddb_table_name}"
      }
    ]
  })
}


# Adjuntar políticas al rol

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "extra_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_extra_policy.arn
}


# Lambda (subiendo el JAR directamente)

resource "aws_lambda_function" "inscripciones" {
  function_name = var.lambda_function_name
  runtime       = "java17"
  handler       = var.lambda_handler                # ej: com.academia.HelloLambda::handleRequest
  role          = aws_iam_role.lambda_exec.arn

  # Ruta al JAR ya compilado
  filename         = "${path.module}/java/target/inscripciones.jar"
  source_code_hash = filebase64sha256("${path.module}/java/target/inscripciones.jar")

  timeout     = 15
  memory_size = 512

  environment {
    variables = {
      DDB_TABLE = var.ddb_table_name
      STAGE     = var.stage
    }
  }
}


# Variables

variable "aws_region" {
  description = "Región AWS"
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
  # Cambia si tu clase real es otra, p.ej: com.academia.InscripcionService::handleRequest
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


# Outputs

output "lambda_name" {
  value = aws_lambda_function.inscripciones.function_name
}
output "lambda_arn" {
  value = aws_lambda_function.inscripciones.arn
}
