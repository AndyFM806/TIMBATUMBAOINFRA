output "api_id"                  { value = aws_apigatewayv2_api.http.id }
output "stage_name"              { value = aws_apigatewayv2_stage.prod.name }
output "api_endpoint"            { value = aws_apigatewayv2_api.http.api_endpoint }
output "api_invoke_url"          { value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}" }
output "api_route_inscripciones" { value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}/inscripciones" }
output "api_stage_arn" {
  description = "ARN del stage principal (prod) del API HTTP."
  value       = aws_apigatewayv2_stage.prod.arn
}
