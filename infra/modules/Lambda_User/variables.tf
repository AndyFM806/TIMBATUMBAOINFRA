# Variables para RDS Proxy y configuración de red
variable "db_proxy_endpoint" {
  description = "Endpoint del RDS Proxy"
  type        = string
}

variable "db_proxy_name" {
  description = "Nombre del RDS Proxy"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN del secret de Secrets Manager con credenciales de BD"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_port" {
  description = "Puerto de la base de datos (3306 para MySQL, 5432 para PostgreSQL)"
  type        = number
  default     = 5432
}

variable "vpc_id" {
  description = "ID de la VPC donde se deployará Lambda"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

variable "lambda_subnet_ids" {
  description = "IDs de las subnets privadas para Lambda"
  type        = list(string)
}