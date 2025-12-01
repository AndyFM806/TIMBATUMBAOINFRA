output "lambda_function_arn" {
  description = "El ARN de la función Lambda."
  value       = aws_lambda_function.this.arn
}

output "lambda_function_name" {
  description = "El nombre de la función Lambda."
  value       = aws_lambda_function.this.function_name
}

output "lambda_iam_role_arn" {
  description = "El ARN del rol de IAM de la Lambda."
  value       = aws_iam_role.lambda_exec.arn
}
