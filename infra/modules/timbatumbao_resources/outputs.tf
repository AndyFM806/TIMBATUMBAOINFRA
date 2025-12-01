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
