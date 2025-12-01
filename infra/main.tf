terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Puedes cambiar la región si lo necesitas
}

# Clave KMS para cifrar los recursos de la aplicación
resource "aws_kms_key" "timbatumbao_key" {
  description             = "KMS key for Timbatumbao application resources"
  deletion_window_in_days = 10
  enable_key_rotation   = true
}

# Tabla DynamoDB para almacenar las inscripciones
resource "aws_dynamodb_table" "timbatumbao_table" {
  name             = "timbatumbao_table"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "PK" # Partition Key
  range_key        = "SK" # Sort Key

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.timbatumbao_key.arn
  }

  tags = {
    Name        = "timbatumbao-table"
    Environment = "dev"
  }
}

# Cola SQS para procesar pagos de forma asíncrona
resource "aws_sqs_queue" "payment_queue" {
  name                        = "timbatumbao-payment-queue"
  kms_master_key_id           = aws_kms_key.timbatumbao_key.arn
  kms_data_key_reuse_period_seconds = 300
}

# Tema SNS para notificar los resultados de la inscripción
resource "aws_sns_topic" "timbatumbao_notifications" {
  name              = "timbatumbao-notifications-topic"
  kms_master_key_id = aws_kms_key.timbatumbao_key.arn
}

# --- Salidas de los recursos principales ---

output "timbatumbao_kms_key_arn" {
  description = "ARN of the central KMS key"
  value       = aws_kms_key.timbatumbao_key.arn
}

output "timbatumbao_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.timbatumbao_table.name
}

output "payment_queue_url" {
  description = "URL of the SQS payment queue"
  value       = aws_sqs_queue.payment_queue.id
}

output "payment_queue_arn" {
  description = "ARN of the SQS payment queue"
  value       = aws_sqs_queue.payment_queue.arn
}

output "timbatumbao_notifications_topic_arn" {
  description = "ARN of the SNS notifications topic"
  value       = aws_sns_topic.timbatumbao_notifications.arn
}
