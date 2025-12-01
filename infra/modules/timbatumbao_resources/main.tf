resource "aws_sns_topic" "notifications" {
  name = var.sns_notifications_topic_name
  kms_master_key_id = aws_kms_key.encryption_key.id
}

resource "aws_kms_key" "encryption_key" {
  description             = "KMS key for encrypting resources"
  deletion_window_in_days = 7
}

resource "aws_sqs_queue" "inscripciones_queue" {
  name                        = var.sqs_queue_name
  kms_master_key_id           = aws_kms_key.encryption_key.id
  kms_data_key_reuse_period_seconds = 300
  receive_wait_time_seconds   = 10
  visibility_timeout_seconds  = 300
}