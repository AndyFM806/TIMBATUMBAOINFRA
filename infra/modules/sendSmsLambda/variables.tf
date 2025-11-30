variable "lambda_function_name" {
  description = "Nombre de la función Lambda sendSms."
  type        = string
}

variable "lambda_handler" {
  description = "Handler de la Lambda (por ejemplo: handler.lambda_handler)."
  type        = string
}

variable "runtime" {
  description = "Runtime de la Lambda (python3.12, nodejs20.x, etc.)."
  type        = string
  default     = "python3.12"
}

variable "stage" {
  description = "Entorno lógico (Dev/QA/Prod)."
  type        = string
}

variable "aws_region" {
  description = "Región AWS."
  type        = string
}

variable "ddb_table_name" {
  description = "Nombre de la tabla DynamoDB donde se registran los SMS/notificaciones."
  type        = string
}

variable "lambda_zip_path" {
  description = "Ruta al ZIP con el código de la Lambda sendSms."
  type        = string
}
