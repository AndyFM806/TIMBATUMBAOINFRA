
# Variables locales (paths internos del módulo)
locals {
  # La ruta del JAR debe ser la ruta ABSOLUTA/RELATIVA al módulo.
  # El path.module garantiza que siempre apunte a la carpeta actual del módulo.
  jar_path_abs = "${path.module}/java/target/inscripciones.jar"
}

# -----------------------------------------------------------------------------
# IAM Role para Lambda
# -----------------------------------------------------------------------------

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-${var.lambda_function_name}-exec-role-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

# Logs básicos
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Acceso administrado a DynamoDB (ajusta si quieres solo ReadOnly)
resource "aws_iam_role_policy_attachment" "dynamodb_managed" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# -----------------------------------------------------------------------------
# Lambda (Java 17)
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "inscripciones" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.lambda_handler
  runtime       = "java17"

  # Empaquetado: JAR ya compilado
  # Usamos la ruta local al JAR compilado dentro de la estructura de tu proyecto.
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

  tags = {
    Service     = var.lambda_function_name
    Environment = var.stage
  }
}