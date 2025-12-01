output "arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.processor_this.arn
}

output "name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.processor_this.function_name
}
