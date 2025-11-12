#############################################
# variables.tf — Variables globales (ROOT)
#############################################

# 🌎 AWS Provider
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

# 🏷️ Etapa / entorno
variable "stage" {
  description = "Entorno lógico para tags y configuración (Dev/QA/Prod)."
  type        = string
  validation {
    condition     = contains(["Dev","QA","Prod","dev","qa","prod"], var.stage)
    error_message = "stage debe ser uno de: Dev, QA o Prod (mayúscula o minúscula)."
  }
}

# 🌐 CORS — API Gateway
variable "allowed_origins" {
  description = "Orígenes permitidos para CORS del API Gateway HTTP."
  type        = list(string)
  default     = ["*"] # Reemplazar por dominios reales cuando se tengan.
}

# 🧠 Cognito / Autenticación
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

# 🧩 Lambda
variable "lambda_function_name" {
  description = "Nombre de la función AWS Lambda."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9-_]{1,64}$", var.lambda_function_name))
    error_message = "lambda_function_name solo puede contener letras, números, guion (-) y guion bajo (_)."
  }
}

variable "lambda_handler" {
  description = "Handler Java en formato paquete.Clase::metodo (ej. com.academia.ApiHandler::handleRequest)."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9_.]+::[A-Za-z0-9_]+$", var.lambda_handler))
    error_message = "lambda_handler debe tener el formato paquete.Clase::metodo."
  }
}

variable "jar_path" {
  description = "Ruta al JAR (fat/uber JAR) que se subirá a la Lambda."
  type        = string
}

# 🪣 DynamoDB
variable "ddb_table_name" {
  description = "Nombre de la tabla DynamoDB usada por la Lambda."
  type        = string
}

# 📬 SQS
variable "sqs_queue_name" {
  description = "Nombre de la cola SQS principal (sin espacios)."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,80}(\\.fifo)?$", var.sqs_queue_name))
    error_message = "sqs_queue_name: 1–80 chars, sin espacios; letras, números, - o _. Para FIFO debe terminar en .fifo."
  }
}
