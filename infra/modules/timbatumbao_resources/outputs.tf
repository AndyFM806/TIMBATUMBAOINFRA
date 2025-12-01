output "kms_key_arn" {
  description = "The ARN of the KMS key."
  value       = aws_kms_key.encryption_key.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.notifications.arn
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue."
  value       = aws_sqs_queue.inscripciones_queue.arn
}
