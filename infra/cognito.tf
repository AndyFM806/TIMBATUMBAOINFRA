# cognito.tf
resource "aws_cognito_user_pool" "tapp" { name = "tapp-users" }

resource "aws_cognito_user_pool_client" "web" {
  name         = "tapp-web"
  user_pool_id = aws_cognito_user_pool.tapp.id
  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["email","openid","profile"]
  callback_urls        = ["https://<tu-cloudfront-domain>/callback"]
  logout_urls          = ["https://<tu-cloudfront-domain>/logout"]
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.http.id
  name             = "cognito-authz"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.web.id]
    issuer   = "https://${aws_cognito_user_pool.tapp.endpoint}"
  }
}

# ejemplo: proteger la ruta
resource "aws_apigatewayv2_route" "inscripciones_auth" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /inscripciones"
  target    = "integrations/${aws_apigatewayv2_integration.inscripciones.id}"
  authorizer_id = aws_apigatewayv2_authorizer.cognito.id
  authorization_type = "JWT"
}
