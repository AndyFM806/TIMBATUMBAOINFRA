variable "allowed_origins" {
  description = "Orígenes permitidos para CORS"
  type        = list(string)
}

variable "lambda_arn" {
  description = "ARN de la Lambda integrada al API"
  type        = string
}

# --- Cognito (JWT) opcional ---
variable "enable_cognito_auth" {
  description = "Habilitar authorizer JWT (Cognito)"
  type        = bool
  default     = false
}

variable "jwt_issuer" {
  description = "Issuer de Cognito: https://cognito-idp.<region>.amazonaws.com/<userPoolId>"
  type        = string
  default     = null
}

variable "jwt_audiences" {
  description = "Audiencias permitidas (Client IDs)"
  type        = list(string)
  default     = []
}
