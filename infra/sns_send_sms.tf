##############################################
# SNS Topic - Notificaciones de inscripciones/pagos
##############################################
resource "aws_sns_topic" "payment_notifications" {
  name = "tapp-payment-notifications"
}

##############################################
# Módulo Lambda sendSms
##############################################
module "send_sms_lambda" {
  source = "./modules/sendSmsLambda"

  lambda_function_name = "sendSms"
  lambda_handler       = "handler.lambda_handler"
  runtime              = "python3.12"
  stage                = var.stage

  aws_region      = var.aws_region
  ddb_table_name  = var.ddb_table_name
  lambda_zip_path = var.send_sms_lambda_zip
}

##############################################
# SNS → Lambda sendSms
##############################################
resource "aws_sns_topic_subscription" "send_sms_subscription" {
  topic_arn = aws_sns_topic.payment_notifications.arn
  protocol  = "lambda"
  endpoint  = module.send_sms_lambda.lambda_arn
}

resource "aws_lambda_permission" "allow_sns_invoke_send_sms" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.send_sms_lambda.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.payment_notifications.arn
}
