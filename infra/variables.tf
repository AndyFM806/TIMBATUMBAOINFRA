variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "sqs_queue_name" {
  description = "The name of the SQS queue."
  type        = string
  default     = "timbatumbao-payment-queue"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  type        = string
  default     = "timbatumbao-inscriptions-table"
}

variable "sns_notifications_topic_name" {
  description = "The name of the SNS topic for notifications."
  type        = string
  default     = "timbatumbao-notifications-topic"
}
