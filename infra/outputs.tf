

# Cognito
output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito."
  value       = aws_cognito_user_pool.ttapp_userpool.id
}

output "cognito_user_pool_client_id" {
  description = "ID del App Client asociado al User Pool de Cognito."
  value       = aws_cognito_user_pool_client.ttapp_client.id
}

output "cognito_issuer_url" {
  description = "URL del issuer JWT de Cognito, usada en los authorizers del API Gateway."
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.ttapp_userpool.id}"
}

# 👤 IAM
output "admin_role_arn" {
  description = "ARN del rol de administrador con acceso total a los recursos."
  value       = aws_iam_role.admin_role_ttapp.arn
}

output "secretary_role_arn" {
  description = "ARN del rol de secretaria con permisos restringidos."
  value       = aws_iam_role.secretary_role_ttapp.arn
}

#  S3
output "s3_bucket_name" {
  description = "Nombre del bucket S3 que aloja el sitio web estático."
  value       = aws_s3_bucket.website_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3."
  value       = aws_s3_bucket.website_bucket.arn
}

# CloudFront
output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront asociada al frontend."
  value       = aws_cloudfront_distribution.website_distribution.id
}

output "cloudfront_domain_name" {
  description = "Dominio HTTPS público de CloudFront (usar si no hay dominio propio)."
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

#  WAF
output "waf_name" {
  description = "Nombre de la Web ACL del WAF asociada al API Gateway."
  value       = aws_wafv2_web_acl.api_waf.name
}

output "waf_arn" {
  description = "ARN de la Web ACL del WAF."
  value       = aws_wafv2_web_acl.api_waf.arn
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
  value       = var.lambda_arn
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
