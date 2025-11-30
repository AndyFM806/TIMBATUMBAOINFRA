# modules.tf (ROOT)

module "inscripciones_lambda" {
  source = "./modules/inscripcionesLambda"

  aws_region           = var.aws_region
  lambda_function_name = var.lambda_function_name
  lambda_handler       = var.lambda_handler
  ddb_table_name       = var.ddb_table_name
  stage                = var.stage
  jar_path             = var.jar_path
}


module "api" {
  source = "./modules/api"

  allowed_origins = var.allowed_origins
  lambda_arn      = module.inscripciones_lambda.lambda_arn

  # Cognito (si lo usas)
  enable_cognito_auth = var.enable_cognito_auth
  jwt_issuer          = var.jwt_issuer
  jwt_audiences       = var.jwt_audiences
}
