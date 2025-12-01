# infra/lambda_pagos.tf

# 1. Empaquetar el código fuente de la Lambda
data "archive_file" "lambda_pagos_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../App/lambdas/pagos"
  output_path = "${path.module}/../dist/lambda_pagos.zip"
}

# 2. Grupo de Seguridad para la Lambda (permite tráfico HTTPS saliente)
resource "aws_security_group" "lambda_pagos_sg" {
  name        = "lambda-pagos-sg"
  description = "Allow outbound HTTPS traffic for the Pagos Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS to external payment APIs"
  }

  tags = {
    Name = "lambda-pagos-sg"
  }
}

# 3. Definir el Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_pagos_role" {
  name = "lambda-pagos-role"

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

# 4. Adjuntar políticas de ejecución al Rol
resource "aws_iam_role_policy_attachment" "lambda_pagos_basic" {
  role       = aws_iam_role.lambda_pagos_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_pagos_vpc" {
  role       = aws_iam_role.lambda_pagos_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_pagos_xray" {
  role       = aws_iam_role.lambda_pagos_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_policy" "lambda_pagos_dlq_policy" {
  name        = "lambda_pagos_dlq_policy"
  description = "Policy to allow lambda to send messages to SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.lambda_pagos_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pagos_dlq_attachment" {
  role       = aws_iam_role.lambda_pagos_role.name
  policy_arn = aws_iam_policy.lambda_pagos_dlq_policy.arn
}

# Dead Letter Queue (DLQ) for Lambda
resource "aws_sqs_queue" "lambda_pagos_dlq" {
  name = "lambda-pagos-dlq"
  kms_master_key_id = aws_kms_key.dynamodb.arn
  kms_data_key_reuse_period_seconds = 300
}

# 6. Crear la Función Lambda en AWS
resource "aws_lambda_function" "lambda_pagos" {
  function_name = "LambdaPagos"
  role          = aws_iam_role.lambda_pagos_role.arn
  handler       = "main.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_pagos_zip.output_path
  source_code_hash = data.archive_file.lambda_pagos_zip.output_base64sha256
  timeout          = 30

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_pagos_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_pagos_sg.id]
  }

  tags = {
    Name = "LambdaPagos"
  }

  depends_on = [aws_nat_gateway.main]
}
