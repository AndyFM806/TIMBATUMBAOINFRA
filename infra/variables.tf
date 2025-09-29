variable "project" { type = string }
variable "env"     { type = string }   # dev | qa | prod
variable "region"  { type = string  default = "us-east-2" }

# Dominio raíz (ej: "timbatumbaoapp.com")
variable "root_domain" { type = string }

# Subdominio web (ej: "www")
variable "web_subdomain" { type = string default = "www" }

# DB credentials (mejor vía Secrets Manager, aquí para bootstrap)
variable "db_username" { type = string }
variable "db_password" { type = string sensitive = true }

# Stripe secret (guardado en Secrets Manager)
variable "stripe_secret" { type = string sensitive = true }

# Artefactos de Lambdas (zip/jar) – ajusta rutas
variable "users_artifact"         { type = string }
variable "courses_artifact"       { type = string }
variable "students_artifact"      { type = string }
variable "uploadvoucher_artifact" { type = string }
variable "inscriptions_artifact"  { type = string }
variable "payments_artifact"      { type = string }
variable "sendsms_artifact"       { type = string }
variable "sendemails_artifact"    { type = string }
