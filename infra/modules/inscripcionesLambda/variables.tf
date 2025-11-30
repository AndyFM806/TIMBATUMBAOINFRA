variable "aws_region" {
  description = "Región de AWS, pasada desde el módulo raíz."
  type        = string
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda (ej: inscripcionesLambda)."
  type        = string
}

variable "lambda_handler" {
  description = "Handler Java (ej: com.academia.ApiHandler::handleRequest)."
  type        = string
}

variable "ddb_table_name" {
  description = "Nombre de la tabla DynamoDB usada por la Lambda."
  type        = string
}

variable "stage" {
  description = "Entorno lógico (Dev/QA/Prod)."
  type        = string
}

variable "jar_path" {
  description = "Ruta al JAR desde el módulo raíz. (Se usa para el hash, aunque el local lo redefina)."
  type        = string
}
