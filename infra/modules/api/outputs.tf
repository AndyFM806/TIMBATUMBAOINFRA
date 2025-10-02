output "api_id"                  { value = aws_apigatewayv2_api.http.id }
output "stage_name"              { value = aws_apigatewayv2_stage.prod.name }
output "api_endpoint"            { value = aws_apigatewayv2_api.http.api_endpoint }
output "api_invoke_url"          { value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}" }
output "api_route_inscripciones" { value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}/inscripciones" }
output "authorizer_id"           { value = try(aws_apigatewayv2_authorizer.cognito[0].id, null) }
