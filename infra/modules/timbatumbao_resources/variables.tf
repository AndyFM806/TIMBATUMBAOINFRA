variable "sns_notifications_topic_name" {
  description = "The name of the SNS topic for notifications."
  type        = string
}

variable "sqs_queue_name" {
    description = "The name for the SQS queue."
    type        = string
}