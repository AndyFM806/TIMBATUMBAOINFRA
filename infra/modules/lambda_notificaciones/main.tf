locals {
  jar_path_abs = abspath(var.jar_path)
}

data "aws_caller_identity" "current" {}

# IAM ROLE
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-${var.lambda_function_name}-exec-role-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Basic Logs
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SNS Publish Policy
resource "aws_iam_policy" "sns_publish_policy" {
  name = "lambda-${var.lambda_function_name}-sns-publish"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_publish_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

# Dead Letter Queue (DLQ) for Lambda
resource "aws_sqs_queue" "dlq" {
  name                              = "${var.lambda_function_name}-dlq"
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_iam_policy" "dlq_policy" {
  name        = "lambda-${var.lambda_function_name}-dlq-policy"
  description = "Policy to allow lambda to send messages to SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dlq_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dlq_policy.arn
}

# Security Group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-${var.lambda_function_name}-sg"
  description = "Security group for Lambda ${var.lambda_function_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "lambda-${var.lambda_function_name}-sg"
  }
}

# Code Signing
resource "aws_signer_signing_profile" "signing_profile" {
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "csc" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.signing_profile.arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# LAMBDA JAVA 17
resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.lambda_handler
  runtime       = "java17"

  filename         = "${path.module}/../inscripcionesLambda/java/target/inscripciones.jar"
  source_code_hash = filebase64sha256("${path.module}/../inscripcionesLambda/java/target/inscripciones.jar")

  timeout     = 15
  memory_size = 512

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      STAGE         = var.stage
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  kms_key_arn = var.kms_key_arn

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  reserved_concurrent_executions = 10
  
  code_signing_config_arn = aws_lambda_code_signing_config.csc.arn

  tags = {
    Service     = var.lambda_function_name
    Environment = var.stage
  }
}
