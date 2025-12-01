variable "sqs_queue_name" {
  description = "The name of the SQS queue."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "sns_notifications_topic_name" {
  description = "The name of the SNS topic for notifications."
  type        = string
}
