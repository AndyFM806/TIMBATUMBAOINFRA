variable "aws_region" {
  default = "us-east-1"
}
variable "allowed_origins" {
  type        = list(string)
  description = "Dominios permitidos para CORS"
  default     = ["*"]  # REEMPLAZA por dominios cuando se tengan
}
