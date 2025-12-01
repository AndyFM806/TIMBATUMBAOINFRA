output "name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.lambda_notificaciones.function_name
}
