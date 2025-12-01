# infra/lambda_initial.tf

# 1. Empaquetar el código fuente de la Lambda
data "archive_file" "lambda_initial_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../App/lambdas/initial"
  output_path = "${path.module}/../dist/lambda_initial.zip"
}

# 2. Definir el Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_initial_role" {
  name = "lambda-initial-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Adjuntar la política básica de ejecución al Rol
resource "aws_iam_role_policy_attachment" "lambda_initial_policy" {
  role       = aws_iam_role.lambda_initial_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4. Crear la Función Lambda en AWS
resource "aws_lambda_function" "lambda_initial" {
  function_name = "LambdaInitial"
  role          = aws_iam_role.lambda_initial_role.arn
  handler       = "main.handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_initial_zip.output_path
  source_code_hash = data.archive_file.lambda_initial_zip.output_base64sha256

  tags = {
    Name = "LambdaInitial"
  }
}
