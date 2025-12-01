locals {
  jar_path_abs = "${path.module}/../../App/Inscripciones/target/inscripciones-1.0.0.jar"
}

# Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-exec-role"

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

# Política para logs de CloudWatch
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_function_name}-logging-policy"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Adjuntar política de logs al rol
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Política para acceso a DynamoDB
resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.lambda_function_name}-dynamodb-policy"
  description = "Policy for lambda to access DynamoDB table"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = var.ddb_table_arn
      }
    ]
  })
}

# Adjuntar política de DynamoDB al rol
resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Política para publicar en SNS
resource "aws_iam_policy" "sns_publish" {
  name        = "${var.lambda_function_name}-sns-policy"
  description = "Policy for lambda to publish to SNS topic"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Adjuntar política de SNS al rol
resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sns_publish.arn
}

resource "aws_iam_role_policy_attachment" "lambda_inscripciones_xray_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_inscripciones_vpc_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_inscripciones_dlq_policy" {
  name        = "lambda_inscripciones_dlq_policy"
  description = "Policy to allow lambda to send messages to SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.lambda_inscripciones_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_inscripciones_dlq_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_inscripciones_dlq_policy.arn
}

# Grupo de seguridad para la Lambda
resource "aws_security_group" "lambda_inscripciones_sg" {
  name        = "lambda-inscripciones-sg"
  description = "Grupo de seguridad para la Lambda de inscripciones"
  vpc_id      = var.vpc_id

  tags = {
    Name = "lambda-inscripciones-sg"
  }
}

# Code Signing for Lambda
resource "aws_signer_signing_profile" "lambda_inscripciones_signing_profile" {
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "lambda_inscripciones_csc" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.lambda_inscripciones_signing_profile.arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

# Dead Letter Queue (DLQ) for Lambda
resource "aws_sqs_queue" "lambda_inscripciones_dlq" {
  name = "lambda-inscripciones-dlq"
}

# Función Lambda
resource "aws_lambda_function" "inscripciones" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.lambda_handler
  runtime       = "java17"

  filename         = local.jar_path_abs
  source_code_hash = filebase64sha256(local.jar_path_abs)

  timeout     = 15
  memory_size = 512

  code_signing_config_arn = aws_lambda_code_signing_config.lambda_inscripciones_csc.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_inscripciones_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.lambda_inscripciones_sg.id]
  }

  reserved_concurrent_executions = 10

  environment {
    variables = {
      DDB_TABLE     = var.ddb_table_name
      STAGE         = var.stage
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = {
    Service     = var.lambda_function_name
    Environment = var.stage
  }
}
