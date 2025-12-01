# infra/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# RECURSOS PRINCIPALES (SNS)
# ------------------------------------------------------------------------------

module "core_resources" {
  source = "./modules/timbatumbao_resources"

  sns_notifications_topic_name = var.sns_notifications_topic_name
}

# ------------------------------------------------------------------------------
# CLAVE KMS PARA CIFRADO
# ------------------------------------------------------------------------------

resource "aws_kms_key" "encryption_key" {
  description = "KMS key for encrypting TappInscripciones environment variables"
  is_enabled  = true
  policy      = <<EOF
  {
    "Id": "key-default-1",
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::327903111118:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow access for CloudWatch Logs",
        "Effect": "Allow",
        "Principal": {
          "Service": "logs.us-east-1.amazonaws.com"
        },
        "Action": [
          "kms:CreateGrant",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow access for API Gateway",
        "Effect": "Allow",
        "Principal": {
          "Service": "apigateway.amazonaws.com"
        },
        "Action": "kms:Get*",
        "Resource": "*"
      },
      {
        "Sid": "Allow VPC Flow Logs to use the key",
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey",
            "kms:CreateGrant"
        ],
        "Resource": "*"
      }
    ]
  }
EOF
}

# ------------------------------------------------------------------------------
# MÓDULOS LAMBDA
# ------------------------------------------------------------------------------

module "enrollment_handler" {
  source = "./modules/lambda_initial"

  function_name     = "EnrollmentRequestHandler"
  source_file       = "../App/lambdas/initial/index.js"
  payment_queue_url = aws_sqs_queue.lambda_pagos_dlq.id
  kms_key_arn       = aws_kms_key.encryption_key.arn
}

module "payment_processor" {
  source = "./modules/lambda_processor"

  processor_function_name = "PaymentProcessor"
  processor_source_file   = "../App/lambdas/pagos/main.py"
  payment_queue_arn       = aws_sqs_queue.lambda_pagos_dlq.arn
  dynamodb_table_name     = aws_dynamodb_table.inscripciones_table.name
  sns_topic_arn           = module.core_resources.timbatumbao_notifications_topic_arn
  processor_kms_key_arn   = aws_kms_key.encryption_key.arn
}

module "notifier" {
  source = "./modules/lambda_notificaciones"

  function_name = "Notifier"
  source_file   = "../App/lambdas/notificaciones/main.py"
  sns_topic_arn = module.core_resources.timbatumbao_notifications_topic_arn
  kms_key_arn   = aws_kms_key.encryption_key.arn
}

# ------------------------------------------------------------------------------
# API GATEWAY
# ------------------------------------------------------------------------------

module "api" {
  source = "./modules/api"

  lambda_arn      = module.enrollment_handler.arn
  kms_key_arn     = aws_kms_key.encryption_key.arn
  allowed_origins = ["*"]
}
