resource "aws_sns_topic" "payment_notifications" {
  name = "payment-notifications-topic"
  kms_master_key_id = aws_kms_key.dynamodb.arn
}
