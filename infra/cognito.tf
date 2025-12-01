# infra/cognito.tf

# 1. Crear el User Pool de Cognito
resource "aws_cognito_user_pool" "user_pool" {
  name = "tapp-user-pool"

  # Configuración de políticas de contraseña (ejemplo simple)
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # Permitir a los usuarios registrarse con su email
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  auto_verified_attributes = ["email"]

  tags = {
    Name = "tapp-user-pool"
  }
}

# 2. Crear un Cliente para el User Pool
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name = "tapp-frontend-client"

  user_pool_id = aws_cognito_user_pool.user_pool.id

  # Para aplicaciones de frontend (Single Page Apps), es mejor no generar un secreto
  generate_secret = false

  # Flujos de autenticación permitidos (SRP es el más seguro para web)
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}
