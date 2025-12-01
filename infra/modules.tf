# modules.tf (ROOT)

module "inscripciones_lambda" {
  source = "./modules/inscripcionesLambda"

  aws_region           = var.aws_region
  lambda_function_name = var.lambda_function_name
  lambda_handler       = var.lambda_handler
  ddb_table_name       = var.ddb_table_name
  stage                = var.stage
  jar_path             = var.jar_path
  sns_topic_arn        = module.timbatumbao_resources.timbatumbao_notifications_topic_arn
  kms_key_arn          = module.timbatumbao_resources.timbatumbao_kms_key_arn
  vpc_id               = aws_vpc.main.id
  subnet_ids           = [aws_subnet.private.id]
}

module "api" {
  source = "./modules/api"

  allowed_origins    = var.allowed_origins
  lambda_arn         = module.inscripciones_lambda.lambda_arn
  lambda_initial_arn = module.enrollment_handler_lambda.arn
  lambda_pagos_arn   = module.payment_processor_lambda.arn
  enable_pagos_route = true
  enable_initial_route = true

  # --- Cognito Activado ---
  enable_cognito_auth = true # <-- Encendemos la autenticación
  jwt_issuer          = aws_cognito_user_pool.user_pool.endpoint
  jwt_audiences       = [aws_cognito_user_pool_client.user_pool_client.id]
  kms_key_arn         = module.timbatumbao_resources.timbatumbao_kms_key_arn
}
