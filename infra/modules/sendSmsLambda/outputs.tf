output "lambda_arn" {
  description = "ARN de la Lambda sendSms."
  value       = aws_lambda_function.send_sms.arn
}

output "lambda_name" {
  description = "Nombre de la Lambda sendSms."
  value       = aws_lambda_function.send_sms.function_name
}
