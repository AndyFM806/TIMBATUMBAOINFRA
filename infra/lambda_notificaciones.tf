# infra/lambda_notificaciones.tf

# 1. Empaquetar el código fuente de la Lambda
data "archive_file" "lambda_notificaciones_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../App/lambdas/notificaciones"
  output_path = "${path.module}/../dist/lambda_notificaciones.zip"
}

# 2. Definir el Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_notificaciones_role" {
  name = "lambda-notificaciones-role"

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
resource "aws_iam_role_policy_attachment" "lambda_notificaciones_basic" {
  role       = aws_iam_role.lambda_notificaciones_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_notificaciones_xray_policy" {
  role       = aws_iam_role.lambda_notificaciones_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_notificaciones_vpc_policy" {
  role       = aws_iam_role.lambda_notificaciones_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_notificaciones_dlq_policy" {
  name        = "lambda_notificaciones_dlq_policy"
  description = "Policy to allow lambda to send messages to SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.lambda_notificaciones_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_notificaciones_dlq_attachment" {
  role       = aws_iam_role.lambda_notificaciones_role.name
  policy_arn = aws_iam_policy.lambda_notificaciones_dlq_policy.arn
}

# Grupo de seguridad para la Lambda
resource "aws_security_group" "lambda_notificaciones_sg" {
  name        = "lambda-notificaciones-sg"
  description = "Grupo de seguridad para la Lambda de notificaciones"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "lambda-notificaciones-sg"
  }
}

# Code Signing for Lambda
resource "aws_signer_signing_profile" "lambda_notificaciones_signing_profile" {
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "lambda_notificaciones_csc" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.lambda_notificaciones_signing_profile.arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

# Dead Letter Queue (DLQ) for Lambda
resource "aws_sqs_queue" "lambda_notificaciones_dlq" {
  name = "lambda-notificaciones-dlq"
}

# 4. Crear la Función Lambda en AWS
resource "aws_lambda_function" "lambda_notificaciones" {
  function_name = "LambdaNotificaciones"
  role          = aws_iam_role.lambda_notificaciones_role.arn
  handler       = "main.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_notificaciones_zip.output_path
  source_code_hash = data.archive_file.lambda_notificaciones_zip.output_base64sha256
  timeout          = 10

  code_signing_config_arn = aws_lambda_code_signing_config.lambda_notificaciones_csc.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_notificaciones_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_notificaciones_sg.id]
  }

  reserved_concurrent_executions = 10

  tags = {
    Name = "LambdaNotificaciones"
  }
}

# 5. Suscribir la Lambda al Tema de SNS
resource "aws_sns_topic_subscription" "lambda_notificaciones_subscription" {
  topic_arn = aws_sns_topic.payment_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_notificaciones.arn
}

# 6. Dar permiso a SNS para que invoque la Lambda
resource "aws_lambda_permission" "sns_invoke_lambda" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = aws_lambda_function.lambda_notificaciones.function_name
  source_arn    = aws_sns_topic.payment_notifications.arn
}
