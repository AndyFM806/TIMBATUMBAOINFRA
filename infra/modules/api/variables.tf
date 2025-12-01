variable "allowed_origins" {
  description = "Orígenes permitidos para CORS"
  type        = list(string)
}

variable "lambda_arn" {
  description = "ARN de la Lambda integrada al API"
  type        = string
}

variable "lambda_initial_arn" {
  description = "ARN de la Lambda 'Initial' para la ruta GET /initial"
  type        = string
  default     = null
}

variable "lambda_pagos_arn" {
  description = "ARN de la Lambda 'Pagos' para la ruta POST /pagos"
  type        = string
  default     = null
}

variable "enable_pagos_route" {
  description = "Enable the /pagos route"
  type        = bool
  default     = false
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

variable "kms_key_arn" {
  description = "ARN de la clave KMS para cifrar los logs de CloudWatch"
  type        = string
}
