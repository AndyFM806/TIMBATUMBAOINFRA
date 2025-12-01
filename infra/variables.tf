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

variable "stage" {
  description = "The deployment stage."
  type        = string
  default     = "dev"
}

variable "ddb_table_name" {
  description = "The name of the DynamoDB table."
  type        = string
  default     = "timbatumbao-inscriptions-table"
}

variable "allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "enable_cognito_auth" {
  description = "Enable Cognito JWT authorizer"
  type        = bool
  default     = false
}

variable "jwt_issuer" {
  description = "Cognito issuer URL"
  type        = string
  default     = null
}

variable "jwt_audiences" {
  description = "Cognito audiences"
  type        = list(string)
  default     = []
}
