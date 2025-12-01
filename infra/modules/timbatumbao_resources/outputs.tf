# --- outputs del módulo timbatumbao_resources ---

output "timbatumbao_kms_key_arn" {
  description = "ARN de la clave KMS para cifrar los recursos de la aplicación"
  value       = aws_kms_key.timbatumbao_key.arn
}

output "timbatumbao_notifications_topic_arn" {
  description = "ARN del tema SNS para notificaciones"
  value       = aws_sns_topic.timbatumbao_notifications.arn
}
