output "lambda_function_name" {
  value       = aws_lambda_function.this.function_name
  description = "Nombre de la función Lambda desplegada"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.this.arn
  description = "ARN de la función Lambda"
}