# MÓDULO: LAMBDA (Java 17)
# - Crea la función Lambda
# - EXPONE outputs (arn y nombre)
# - NO incluye permisos de API Gateway (eso va en el módulo del API)



# Variables del módulo
locals {
  jar_path_abs = "${path.module}/java/target/inscripciones.jar"
}
variable "aws_region"           { type = string }
variable "lambda_function_name" { type = string }   # ej: "inscripciones"
variable "lambda_handler"       { type = string }   # ej: "com.academia.HelloLambda::handleRequest"
variable "ddb_table_name"       { type = string }   # si no usas DDB, puedes pasar "" y quitar política
variable "stage"                { type = string }   # Dev/QA/Prod
variable "jar_path"             { type = string }   # ruta absoluta/relativa al JAR


# IAM Role para Lambda

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-${var.lambda_function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

# Logs básicos (déjalo igual)
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Acceso administrado a DynamoDB (ajusta si quieres solo ReadOnly)
resource "aws_iam_role_policy_attachment" "dynamodb_managed" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


# Lambda (Java 17)

resource "aws_lambda_function" "inscripciones" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.lambda_handler
  runtime       = "java17"

  # Empaquetado: JAR ya compilado
  filename         = local.jar_path_abs
  source_code_hash = filebase64sha256(local.jar_path_abs)

  timeout     = 15
  memory_size = 512

  environment {
    variables = {
      DDB_TABLE = var.ddb_table_name
      STAGE     = var.stage
    }
  }

}

