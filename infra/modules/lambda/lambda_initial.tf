# infra/modules/lambda/lambda_initial.tf

# KMS Key for environment variable encryption
resource "aws_kms_key" "initial_lambda_env_key" {
  description             = "KMS key for encrypting Lambda environment variables for initial_lambda"
  deletion_window_in_days = 7
  enable_key_rotation   = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "kms-key-policy",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

# Dead Letter Queue for the Lambda
resource "aws_sqs_queue" "initial_lambda_dlq" {
  name = "initial-lambda-dlq"
  sqs_managed_sse_enabled = true
}

# Security Group for the Lambda
resource "aws_security_group" "initial_lambda_sg" {
  name        = "initial-lambda-sg"
  description = "Security group for the initial Lambda function"
  vpc_id      = var.vpc_id # Assumes vpc_id is passed into the module

  tags = {
    Name = "initial-lambda-sg"
  }
}

# Code Signing configuration
resource "aws_signer_signing_profile" "initial_lambda_signing_profile" {
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "initial_lambda_csc" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.initial_lambda_signing_profile.arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

resource "aws_lambda_function" "initial_lambda" {
  function_name = "Lambda-Initial"
  role          = aws_iam_role.admin_role_ttapp.arn
  handler       = var.lambda_handler
  runtime       = "python3.12"

  filename         = "${path.module}/../lambda/initial_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/initial_lambda.zip")

  # Configurations to fix reported issues
  reserved_concurrent_executions = 10
  kms_key_arn                  = aws_kms_key.initial_lambda_env_key.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.initial_lambda_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids # Assumes subnet_ids are passed into the module
    security_group_ids = [aws_security_group.initial_lambda_sg.id]
  }

  code_signing_config_arn = aws_lambda_code_signing_config.initial_lambda_csc.arn

  environment {
    variables = {
      STAGE         = var.stage
      PAYMENT_QUEUE = aws_sqs_queue.payment_queue.url
    }
  }

  tags = {
    Name        = "Lambda-Initial"
    Environment = var.stage
  }
}

data "aws_caller_identity" "current" {}
