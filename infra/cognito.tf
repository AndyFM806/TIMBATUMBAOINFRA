# Amazon Cognito - User Pool

resource "aws_cognito_user_pool" "ttapp_userpool" {
  name = "cognito-userpool-TTapp"

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  mfa_configuration = "OFF"

  tags = {
    Environment = "Dev"
    Name        = "TimbaTumbao Cognito"
  }
}

# Cognito App Client
resource "aws_cognito_user_pool_client" "ttapp_client" {
  name         = "timbatumbao-client"
  user_pool_id = aws_cognito_user_pool.ttapp_userpool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]



  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 7

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# Cognito User Groups

resource "aws_cognito_user_group" "admin_group" {
  name         = "AdminRole-TTApp"
  user_pool_id = aws_cognito_user_pool.ttapp_userpool.id
  description  = "Grupo de administradores con acceso total"
  precedence   = 1
}

resource "aws_cognito_user_group" "secretary_group" {
  name         = "SecretaryRole-TTApp"
  user_pool_id = aws_cognito_user_pool.ttapp_userpool.id
  description  = "Grupo de secretarias con acceso limitado"
  precedence   = 2
}

# API Gateway Authorizer (JWT)

resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id           = module.api.api_id
  name             = "cognito-authorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.ttapp_userpool.id}"
    audience = [aws_cognito_user_pool_client.ttapp_client.id]
  }
}
