# Outputs útiles del API
output "api_id" {
  value = aws_apigatewayv2_api.http.id
}

output "api_endpoint" {
  # URL base del stage (ej: https://abc123.execute-api.us-east-1.amazonaws.com/prod)
  value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}"
}

output "api_route_inscripciones" {
  # URL completa de la ruta POST /inscripciones (informativo)
  value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}/inscripciones"
}
