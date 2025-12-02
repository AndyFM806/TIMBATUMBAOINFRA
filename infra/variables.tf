
variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "sqs_queue_name" {
  description = "The name of the SQS queue."
  type        = string
  default     = "inscripciones-queue"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  type        = string
  default     = "InscripcionesTable"
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

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = ""
}

variable "jar_path" {
  description = "The path to the JAR file."
  type        = string
  default     = ""
}

variable "handler" {
  description = "The handler for the Lambda function."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "The runtime for the Lambda function."
  type        = string
  default     = ""
}

variable "bucket_name" {
  type = string
}
