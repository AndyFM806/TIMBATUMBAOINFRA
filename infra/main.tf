module "network" {
  source       = "./modules/network"
  project      = var.project
  env          = var.env
  vpc_cidr     = "10.20.0.0/16"
  public_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
  private_cidrs= ["10.20.10.0/24","10.20.11.0/24"]
}

module "iam" {
  source  = "./modules/iam"
  project = var.project
  env     = var.env
}

module "rds_mysql" {
  source          = "./modules/rds_mysql"
  project         = var.project
  env             = var.env
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnet_ids
  db_username     = var.db_username
  db_password     = var.db_password
  lambda_sg_id    = module.network.lambda_sg_id
}

module "cognito" {
  source  = "./modules/cognito"
  project = var.project
  env     = var.env
}

# Lambdas (todas usan rol de ejecución del módulo IAM y SG/subnets para VPC cuando acceden a RDS/Proxy)
module "lambda_users" {
  source        = "./modules/lambda_generic"
  name          = "UsersLambda"
  project       = var.project
  env           = var.env
  artifact_path = var.users_artifact
  role_arn      = module.iam.lambda_exec_role_arn
}

module "lambda_courses" {
  source        = "./modules/lambda_generic"
  name          = "CoursesLambda"
  project       = var.project
  env           = var.env
  artifact_path = var.courses_artifact
  role_arn      = module.iam.lambda_exec_role_arn
}

module "lambda_students" {
  source        = "./modules/lambda_generic"
  name          = "StudentsLambda"
  project       = var.project
  env           = var.env
  artifact_path = var.students_artifact
  role_arn      = module.iam.lambda_exec_role_arn
  use_vpc       = true
  subnets       = module.network.private_subnet_ids
  security_groups = [module.network.lambda_sg_id]
  env_vars = {
    DB_ENDPOINT  = module.rds_mysql.proxy_endpoint
    DB_USER      = var.db_username
  }
}

module "lambda_uploadvoucher" {
  source        = "./modules/lambda_generic"
  name          = "UploadVoucher"
  project       = var.project
  env           = var.env
  artifact_path = var.uploadvoucher_artifact
  role_arn      = module.iam.lambda_exec_role_arn
}

module "lambda_inscriptions" {
  source        = "./modules/lambda_generic"
  name          = "InscriptionsLambda"
  project       = var.project
  env           = var.env
  artifact_path = var.inscriptions_artifact
  role_arn      = module.iam.lambda_exec_role_arn
  use_vpc       = true
  subnets       = module.network.private_subnet_ids
  security_groups = [module.network.lambda_sg_id]
  env_vars = {
    DB_ENDPOINT = module.rds_mysql.proxy_endpoint
  }
}

module "lambda_payments" {
  source        = "./modules/lambda_generic"
  name          = "PaymentsLambda"
  project       = var.project
  env           = var.env
  artifact_path = var.payments_artifact
  role_arn      = module.iam.lambda_exec_role_arn
  use_vpc       = true
  subnets       = module.network.private_subnet_ids
  security_groups = [module.network.lambda_sg_id]
  env_vars = {
    STRIPE_SECRET = var.stripe_secret
  }
}

module "lambda_sendsms" {
  source        = "./modules/lambda_generic"
  name          = "SendSMS"
  project       = var.project
  env           = var.env
  artifact_path = var.sendsms_artifact
  role_arn      = module.iam.lambda_exec_role_arn
}

module "lambda_sendemails" {
  source        = "./modules/lambda_generic"
  name          = "SendEmails"
  project       = var.project
  env           = var.env
  artifact_path = var.sendemails_artifact
  role_arn      = module.iam.lambda_exec_role_arn
}

module "messaging" {
  source         = "./modules/messaging"
  project        = var.project
  env            = var.env
  email_queue_dlq_name = "email-dlq"
  email_queue_name     = "email"
}

module "api_gw" {
  source                  = "./modules/api_gateway"
  project                 = var.project
  env                     = var.env
  users_lambda_arn        = module.lambda_users.arn
  courses_lambda_arn      = module.lambda_courses.arn
  students_lambda_arn     = module.lambda_students.arn
  uploadvoucher_lambda_arn= module.lambda_uploadvoucher.arn
  inscriptions_lambda_arn = module.lambda_inscriptions.arn
  payments_lambda_arn     = module.lambda_payments.arn
  cognito_user_pool_arn   = module.cognito.user_pool_arn
}

module "s3_cloudfront" {
  source        = "./modules/s3_cloudfront"
  project       = var.project
  env           = var.env
  root_domain   = var.root_domain
  web_subdomain = var.web_subdomain
}

module "waf" {
  source             = "./modules/waf"
  project            = var.project
  env                = var.env
  apigw_arn          = module.api_gw.stage_arn
  cloudfront_arn     = module.s3_cloudfront.cf_arn
}

module "monitoring" {
  source        = "./modules/monitoring"
  project       = var.project
  env           = var.env
  lambda_arns   = [
    module.lambda_users.arn,
    module.lambda_courses.arn,
    module.lambda_students.arn,
    module.lambda_uploadvoucher.arn,
    module.lambda_inscriptions.arn,
    module.lambda_payments.arn,
    module.lambda_sendsms.arn,
    module.lambda_sendemails.arn
  ]
  db_instance_arn = module.rds_mysql.rds_arn
}
