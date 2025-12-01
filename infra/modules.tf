# modules.tf (ROOT)

module "inscripciones_lambda" {
  source = "./modules/inscripcionesLambda"

  aws_region           = var.aws_region
  lambda_function_name = var.lambda_function_name
  lambda_handler       = var.lambda_handler
  ddb_table_name       = var.ddb_table_name
  stage                = var.stage
  jar_path             = var.jar_path
  sns_topic_arn        = aws_sns_topic.payment_notifications.arn
}

module "api" {
  source = "./modules/api"

  allowed_origins    = var.allowed_origins
  lambda_arn         = module.inscripciones_lambda.lambda_arn
  lambda_initial_arn = aws_lambda_function.lambda_initial.arn
  lambda_pagos_arn   = aws_lambda_function.lambda_pagos.arn

  # --- Cognito Activado ---
  enable_cognito_auth = true # <-- Encendemos la autenticación
  jwt_issuer          = aws_cognito_user_pool.user_pool.endpoint
  jwt_audiences       = [aws_cognito_user_pool_client.user_pool_client.id]
}
