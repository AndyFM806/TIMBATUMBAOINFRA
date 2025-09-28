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
