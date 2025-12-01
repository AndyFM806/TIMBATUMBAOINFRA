
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}


variable "stage" {
  description = "Entorno lógico para tags y configuración (Dev/QA/Prod)."
  type        = string
}


variable "allowed_origins" {
  description = "Orígenes permitidos para CORS del API Gateway HTTP."
  type        = list(string)
  default     = ["*"] # Reemplazar por dominios reales cuando se tengan.
}


variable "enable_cognito_auth" {
  description = "Habilitar el authorizer JWT (Cognito) en las rutas del API."
  type        = bool
  default     = true
}

variable "jwt_issuer" {
  description = "Issuer del JWT de Cognito: https://cognito-idp.<region>.amazonaws.com/<userPoolId>."
  type        = string
  default     = null
}

variable "jwt_audiences" {
  description = "Lista de audiencias válidas (Client IDs del App Client en Cognito)."
  type        = list(string)
  default     = []
}

variable "lambda_function_name" {
  description = "Nombre de la función AWS Lambda."
  type        = string
}

variable "lambda_handler" {
  description = "Handler Java en formato paquete.Clase::metodo."
  type        = string
}

variable "jar_path" {
  description = "Ruta al JAR que se subirá a la Lambda."
  type        = string
}

variable "ddb_table_name" {
  description = "Nombre de la tabla DynamoDB usada por la Lambda."
  type        = string
}

variable "ses_sender_email" {
  description = "Email verificado en SES que se usará como remitente (From)."
  type        = string
  default     = "noreply@example.com"
}
