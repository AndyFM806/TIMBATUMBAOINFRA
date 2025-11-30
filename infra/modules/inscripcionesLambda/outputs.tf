output "lambda_arn" {
  description = "ARN de la función Lambda de Inscripciones."
  value       = aws_lambda_function.inscripciones.arn
}

output "lambda_name" {
  description = "Nombre de la función Lambda de Inscripciones."
  value       = aws_lambda_function.inscripciones.function_name
}

# El rol puede ser útil si otro recurso necesita permiso para asumir el rol de esta Lambda.
output "lambda_role_arn" {
  description = "ARN del rol de ejecución de la función Lambda."
  value       = aws_iam_role.lambda_exec.arn
}