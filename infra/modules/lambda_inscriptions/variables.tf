variable "project"           { type = string }
variable "env"               { type = string }

variable "lambda_role_arn"   { type = string }
variable "artifact_path"     { type = string } # ej: artifacts/inscripciones.zip

# Opcional VPC (si Lambda accede a RDS privado)
variable "use_vpc" {
  type    = bool
  default = true
}
variable "private_subnets" {
  type    = list(string)
  default = []
}
variable "security_groups" {
  type    = list(string)
  default = []
}

# Para dar permiso de invocación a API Gateway (execution ARN)
variable "api_execution_arn" { type = string }

# Variables de entorno (DB, topics, secretos, etc.)
variable "env_vars" {
  type = map(string)
  default = {
    DB_SECRET_NAME  = ""
    RDS_ENDPOINT    = ""
    RDS_PROXY_ARN   = ""
    SES_SENDER      = ""
    MP_ACCESS_TOKEN = ""   # MercadoPago
    TOPIC_PENDIENTE = ""   # SNS: solicitud_pendiente
    TOPIC_RESULTADO = ""   # SNS: aprobada_rechazada
  }
}
