provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULES
# ----------------------------------------------------------------------------------------------------------------------
module "inscripciones_lambda" {
  source = "./modules/inscripcionesLambda"

  lambda_function_name = "InscripcionesFunction"
    lambda_handler       = "com.academiabaile.backend.handlers.InscripcionHandler::handleRequest"
    jar_path             = "./modules/inscripcionesLambda/java/target/inscripciones.jar"
    stage                = "prod"
    aws_region           = var.aws_region
    ddb_table_name       = aws_dynamodb_table.inscripciones_table.name
    sns_topic_arn        = module.timbatumbao_resources.sns_topic_arn
    kms_key_arn          = module.timbatumbao_resources.kms_key_arn
    vpc_id               = aws_vpc.main.id
    subnet_ids           = [aws_subnet.private.id]
  }

  module "lambda_processor" {
    source = "./modules/lambda_processor"

    lambda_function_name = "PaymentProcessor"
    lambda_handler       = "com.academiabaile.backend.handlers.InscripcionHandler::handleRequest"
    jar_path             = "./modules/inscripcionesLambda/java/target/inscripciones.jar"
    stage                = "prod"
    aws_region           = var.aws_region
    sqs_queue_arn        = module.timbatumbao_resources.sqs_queue_arn
    ddb_table_name       = aws_dynamodb_table.inscripciones_table.name
    sns_topic_arn        = module.timbatumbao_resources.sns_topic_arn
    kms_key_arn          = module.timbatumbao_resources.kms_key_arn
    vpc_id               = aws_vpc.main.id
    subnet_ids           = [aws_subnet.private.id]
  }

  module "lambda_notificaciones" {
    source = "./modules/lambda_notificaciones"

    lambda_function_name = "Notifier"
      lambda_handler       = "com.academiabaile.backend.handlers.InscripcionHandler::handleRequest"
      jar_path             = "./modules/inscripcionesLambda/target/inscripciones.jar"
      stage                = "prod"
      aws_region           = var.aws_region
      sns_topic_arn        = module.timbatumbao_resources.sns_topic_arn
      kms_key_arn          = module.timbatumbao_resources.kms_key_arn
      vpc_id               = aws_vpc.main.id
      subnet_ids           = [aws_subnet.private.id]
    }

    module "api" {
      source = "./modules/api"

      lambda_arn      = module.inscripciones_lambda.lambda_function_arn
      kms_key_arn     = module.timbatumbao_resources.kms_key_arn
      allowed_origins = ["*"]
    }

    module "timbatumbao_resources" {
      source = "./modules/timbatumbao_resources"

      sns_notifications_topic_name = "timbatumbao-notifications"
      sqs_queue_name               = "timbatumbao-inscripciones-queue"
      aws_region                   = var.aws_region
    }
