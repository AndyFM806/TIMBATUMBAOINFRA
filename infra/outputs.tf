output "api_gateway_url" {
  description = "The URL of the API Gateway."
  value       = module.api.api_invoke_url
}

output "timbatumbao_table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.inscripciones_table.name
}
