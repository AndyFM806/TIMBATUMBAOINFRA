# cognito.tf (ROOT) — CORREGIDO

variable "jwt_issuer" {
  description = "Issuer de Cognito: https://cognito-idp.<region>.amazonaws.com/<userPoolId>"
  type        = string
  default     = null
}

variable "jwt_audiences" {
  description = "Audiencias permitidas (Client IDs de tu App Client en Cognito)."
  type        = list(string)
  default     = []
}

# Si aún no usarás Cognito, puedes comentar este recurso,
# o dejar issuer=null / audiences=[]
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = module.api.api_id          # <-- CAMBIO CLAVE
  name             = "cognito-jwt"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = var.jwt_issuer
    audience = var.jwt_audiences
  }
}
