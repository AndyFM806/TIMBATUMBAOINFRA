# --- outputs del módulo timbatumbao_resources ---

output "timbatumbao_kms_key_arn" {
  description = "ARN de la clave KMS para cifrar los recursos de la aplicación"
  value       = aws_kms_key.timbatumbao_key.arn
}

output "timbatumbao_table_name" {
  description = "Nombre de la tabla DynamoDB para las inscripciones"
  value       = aws_dynamodb_table.timbatumbao_table.name
}

output "timbatumbao_table_arn" {
  description = "ARN de la tabla DynamoDB para las inscripciones"
  value       = aws_dynamodb_table.timbatumbao_table.arn
}

output "timbatumbao_queue_url" {
  description = "URL de la cola SQS para procesar pagos"
  value       = aws_sqs_queue.payment_queue.id
}

output "timbatumbao_queue_arn" {
  description = "ARN de la cola SQS para procesar pagos"
  value       = aws_sqs_queue.payment_queue.arn
}

output "timbatumbao_notifications_topic_arn" {
  description = "ARN del tema SNS para notificar los resultados de la inscripción"
  value       = aws_sns_topic.timbatumbao_notifications.arn
}
