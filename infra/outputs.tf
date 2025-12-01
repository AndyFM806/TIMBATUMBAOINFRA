# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------

output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = module.api.api_gateway_url
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.enrollment_handler.arn
}
