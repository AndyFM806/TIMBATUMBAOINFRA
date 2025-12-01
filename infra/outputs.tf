
# Cognito
output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito."
  value       = aws_cognito_user_pool.user_pool.id
}

output "cognito_user_pool_client_id" {
  description = "ID del App Client asociado al User Pool de Cognito."
  value       = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_issuer_url" {
  description = "URL del issuer JWT de Cognito, usada en los authorizers del API Gateway."
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
}

#  API Gateway
output "api_id" {
  description = "ID del API Gateway HTTP."
  value       = module.api.api_id
}

output "api_endpoint" {
  description = "Endpoint del API Gateway HTTP v2."
  value       = module.api.api_endpoint
}

output "api_route_inscripciones" {
  description = "Ruta configurada para POST /inscripciones."
  value       = module.api.api_route_inscripciones
}

# Lambda
output "lambda_function_arn" {
  description = "ARN de la función Lambda (inscripciones)."
  value       = module.inscripciones_lambda.lambda_arn
}



#  Generales
output "aws_region" {
  description = "Región de despliegue en AWS."
  value       = var.aws_region
}

output "environment" {
  description = "Etapa lógica del entorno (Dev/QA/Prod)."
  value       = var.stage
}
