variable "aws_region" {
  description = "Región de AWS, pasada desde el módulo raíz."
  type        = string
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda (ej: PaymentProcessor)."
  type        = string
}

variable "lambda_handler" {
  description = "Handler Java (ej: com.academiabaile.backend.handlers.PaymentProcessorHandler)."
  type        = string
}

variable "jar_path" {
  description = "Ruta al JAR desde el módulo raíz."
  type        = string
}

variable "stage" {
  description = "Entorno lógico (Dev/QA/Prod)."
  type        = string
}

variable "ddb_table_name" {
  description = "Nombre de la tabla DynamoDB usada por la Lambda."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del topic SNS donde publicará la Lambda de procesamiento."
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS que triggera esta Lambda."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para el cifrado."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC para el grupo de seguridad."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs de subred para la configuración de la VPC de la Lambda."
  type        = list(string)
}
