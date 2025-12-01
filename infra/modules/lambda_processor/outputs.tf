output "arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.lambda_processor.arn
}

output "name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.lambda_processor.function_name
}
