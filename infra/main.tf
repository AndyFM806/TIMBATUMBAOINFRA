module "iam" {
  source  = "./modules/iam"
  project = var.project
  env     = var.env
}

module "lambda_students" {
  source          = "./modules/lambda_students"
  project         = var.project
  env             = var.env
  artifact_path   = var.students_artifact
  lambda_role_arn = module.iam.lambda_exec_role_arn
}

module "api_gw" {
  source              = "./modules/api_gateway"
  project             = var.project
  env                 = var.env
  region              = var.region
  students_lambda_arn = module.lambda_students.arn
  students_lambda_name= module.lambda_students.name
}

module "lambda_inscriptions" {
  source            = "./modules/lambda_inscriptions"
  project           = var.project
  env               = var.env

  lambda_role_arn   = module.iam.lambda_exec_role_arn
  artifact_path     = "artifacts/inscripciones.zip"

  use_vpc           = var.use_vpc
  private_subnets   = module.network.private_subnets
  security_groups   = [] # agrega SG si tienes uno para lambdas

  api_execution_arn = module.api_gateway.execution_arn

  env_vars = {
    DB_SECRET_NAME  = var.db_secret_name
    RDS_ENDPOINT    = module.rds.db_endpoint
    RDS_PROXY_ARN   = module.rds.proxy_arn
    SES_SENDER      = var.ses_sender_email
    MP_ACCESS_TOKEN = "arn:aws:secretsmanager:REGION:ACCOUNT:secret:mp-token" # o pásalo por var
    TOPIC_PENDIENTE = module.messaging.sns_topics_arn["solicitud_pendiente"]
    TOPIC_RESULTADO = module.messaging.sns_topics_arn["aprobada_rechazada"]
  }
}
