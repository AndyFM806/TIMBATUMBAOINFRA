
variable "region" {
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nombre del proyecto."
  type        = string
  default     = "TIMBATUMBAO"
}

variable "env" {
  description = "Entorno de despliegue (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "lambda_zip_file" {
  description = "El nombre del archivo .zip de la función Lambda."
  type        = string
  default     = "courses_lambda.zip"
}

# --- Configuración de Red y Base de Datos --- 

variable "use_vpc" {
  description = "Poner en 'true' para conectar la Lambda a la base de datos RDS en la VPC."
  type        = bool
  default     = false
}

variable "private_subnets" {
  description = "IMPORTANTE: Debes proporcionar la lista de IDs de las subredes privadas de tu VPC."
  type        = list(string)
  default     = [] # Ejemplo: ["subnet-0123456789abcdef0", "subnet-fedcba9876543210f"]
}

variable "security_groups" {
  description = "IMPORTANTE: Debes proporcionar la lista de IDs de los grupos de seguridad para la Lambda."
  type        = list(string)
  default     = [] # Ejemplo: ["sg-0123456789abcdef0"]
}

variable "db_secret_arn" {
  description = "IMPORTANTE: Debes proporcionar el ARN del secreto en AWS Secrets Manager que contiene las credenciales de la BD."
  type        = string
  default     = "" # Ejemplo: "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-db-secret-XXXXXX"
}

variable "env_vars" {
  description = "Variables de entorno para la función Lambda."
  type        = map(string)
  default     = {}
}
