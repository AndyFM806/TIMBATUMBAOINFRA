resource "aws_sqs_queue" "payment_queue" {
  name                       = "${var.sqs_queue_name}-payment"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  delay_seconds              = 0
  receive_wait_time_seconds  = 5

  tags = {
    Name        = "PaymentQueue"
    Environment = var.stage
  }
}
