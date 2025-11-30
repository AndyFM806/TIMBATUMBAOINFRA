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
