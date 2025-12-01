variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "source_file" {
  description = "The path to the Lambda function's source code."
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications."
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for encrypting environment variables."
  type        = string
}
