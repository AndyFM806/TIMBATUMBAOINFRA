module "enrollment_handler_lambda" {
  source = "./modules/lambda/lambda_initial"

  function_name     = "EnrollmentRequestHandler"
  payment_queue_url = module.timbatumbao_resources.payment_queue_url
  kms_key_arn       = module.timbatumbao_resources.timbatumbao_kms_key_arn
}

module "payment_processor_lambda" {
  source = "./modules/lambda/lambda_processor"

  processor_function_name = "PaymentProcessor"
  payment_queue_arn      = module.timbatumbao_resources.payment_queue_arn
  dynamodb_table_name    = module.timbatumbao_resources.timbatumbao_table_name
  sns_topic_arn          = module.timbatumbao_resources.timbatumbao_notifications_topic_arn
  processor_kms_key_arn  = module.timbatumbao_resources.timbatumbao_kms_key_arn
}
