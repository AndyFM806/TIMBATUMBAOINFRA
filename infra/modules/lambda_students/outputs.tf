output "arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.this.arn
}

output "name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.this.function_name
}
