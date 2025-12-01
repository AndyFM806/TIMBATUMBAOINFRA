# Clave KMS para cifrar los recursos de la aplicación
resource "aws_kms_key" "timbatumbao_key" {
  description             = "KMS key for Timbatumbao application resources"
  deletion_window_in_days = 10
  enable_key_rotation   = true
}

# Tema SNS para notificar los resultados de la inscripción
resource "aws_sns_topic" "timbatumbao_notifications" {
  name              = var.sns_notifications_topic_name
  kms_master_key_id = aws_kms_key.timbatumbao_key.arn
}
