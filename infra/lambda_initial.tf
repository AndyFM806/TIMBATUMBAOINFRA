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

# 3. Adjuntar políticas de ejecución al Rol
resource "aws_iam_role_policy_attachment" "lambda_initial_policy" {
  role       = aws_iam_role.lambda_initial_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_initial_xray_policy" {
  role       = aws_iam_role.lambda_initial_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_initial_vpc_policy" {
  role       = aws_iam_role.lambda_initial_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_initial_dlq_policy" {
  name        = "lambda_initial_dlq_policy"
  description = "Policy to allow lambda to send messages to SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.lambda_initial_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_initial_dlq_attachment" {
  role       = aws_iam_role.lambda_initial_role.name
  policy_arn = aws_iam_policy.lambda_initial_dlq_policy.arn
}

# Grupo de seguridad para la Lambda
resource "aws_security_group" "lambda_initial_sg" {
  name        = "lambda-initial-sg"
  description = "Security group for the initial Lambda"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "lambda-initial-sg"
  }
}

# Dead Letter Queue (DLQ) for Lambda
resource "aws_sqs_queue" "lambda_initial_dlq" {
  name                              = "lambda-initial-dlq"
  kms_master_key_id                 = aws_kms_key.dynamodb.arn
  kms_data_key_reuse_period_seconds = 300
}

# 4. Crear la Función Lambda en AWS
resource "aws_lambda_function" "lambda_initial" {
  function_name = "LambdaInitial"
  role          = aws_iam_role.lambda_initial_role.arn
  handler       = "main.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_initial_zip.output_path
  source_code_hash = data.archive_file.lambda_initial_zip.output_base64sha256

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_initial_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_initial_sg.id]
  }

  tags = {
    Name = "LambdaInitial"
  }
}
