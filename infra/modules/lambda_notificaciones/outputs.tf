output "name" {
  description = "The name of the Notifier Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "arn" {
  description = "The ARN of the Notifier Lambda function"
  value       = aws_lambda_function.this.arn
}
