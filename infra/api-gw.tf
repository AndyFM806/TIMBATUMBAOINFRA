# API Gateway HTTP para exponer /inscripciones


# 1) Crea el API HTTP

resource "aws_apigatewayv2_api" "http" {
  name          = "tapp-http-api-inscripcciones" 
  protocol_type = "HTTP"

  # CORS: ajusta orígenes y headers a tus necesidades
   cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type", "authorization"]
  }

}

# 2) Stage del API (prod por simplicidad)
#    - auto_deploy = true para que al crear/editar rutas se publiquen automáticamente
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "prod"              # puedes usar "$default" si prefieres
  auto_deploy = true
}

# 3) Integración Lambda proxy (payload v2.0)
#    - integration_uri: ARN de la Lambda ya creado (inscripciones)
resource "aws_apigatewayv2_integration" "inscripciones" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.inscripciones.arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000   # opcional, por defecto 30000 pero quisimos variar
}

# 4) Ruta: POST /inscripciones
resource "aws_apigatewayv2_route" "inscripciones" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /inscripciones"
  target    = "integrations/${aws_apigatewayv2_integration.inscripciones.id}"
}

# 5) Permiso para que API Gateway invoque tu Lambda
resource "aws_lambda_permission" "apigw_invoke_inscripciones" {
  statement_id  = "AllowAPIGWInvokeInscripciones"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inscripciones.function_name
  principal     = "apigateway.amazonaws.com"

  # Permite invocaciones desde cualquier stage/ruta de este API
  source_arn = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
