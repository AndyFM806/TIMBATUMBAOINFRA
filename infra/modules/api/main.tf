# API HTTP + CORS
resource "aws_apigatewayv2_api" "http" {
  name          = "tapp-http-api-inscripciones"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type", "authorization"]
  }
}

# Stage
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "prod"
  auto_deploy = true
}

# Integración Lambda (Inscripciones)
resource "aws_apigatewayv2_integration" "inscripciones" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn
  payload_format_version = "2.0"
}

# Authorizer Cognito opcional
resource "aws_apigatewayv2_authorizer" "cognito" {
  count = var.enable_cognito_auth && var.jwt_issuer != null && length(var.jwt_audiences) > 0 ? 1 : 0

  api_id           = aws_apigatewayv2_api.http.id
  name             = "cognito-authorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = var.jwt_issuer
    audience = var.jwt_audiences
  }
}

# Ruta /inscripciones
resource "aws_apigatewayv2_route" "inscripciones" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /inscripciones"
  target    = "integrations/${aws_apigatewayv2_integration.inscripciones.id}"

  authorization_type = var.enable_cognito_auth && var.jwt_issuer != null && length(var.jwt_audiences) > 0 ? "JWT" : "NONE"
  authorizer_id      = var.enable_cognito_auth && var.jwt_issuer != null && length(var.jwt_audiences) > 0 ? aws_apigatewayv2_authorizer.cognito[0].id : null
}

# Permiso APIGW -> Lambda
resource "aws_lambda_permission" "apigw_invoke_inscripciones" {
  statement_id  = "AllowAPIGWInvokeInscripciones"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = var.lambda_arn
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
