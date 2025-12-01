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
    lambda_handler       = "com.academiabaile.backend.handlers.PaymentHandler"
    jar_path             = "./modules/inscripcionesLambda/java/target/inscripciones.jar"
    stage                = "prod"
    aws_region           = var.aws_region
    sqs_queue_url        = module.timbatumbao_resources.sqs_queue_url
    sns_topic_arn        = module.timbatumbao_resources.sns_topic_arn
    kms_key_arn          = module.timbatumbao_resources.kms_key_arn
    vpc_id               = aws_vpc.main.id
    subnet_ids           = [aws_subnet.private.id]
  }

  module "lambda_notificaciones" {
    source = "./modules/lambda_notificaciones"

    lambda_function_name = "Notifier"
      lambda_handler       = "com.academiabaile.backend.handlers.NotificationHandler"
      jar_path             = "./modules/inscripcionesLambda/java/target/inscripciones.jar"
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
    }

# ----------------------------------------------------------------------------------------------------------------------
# DYNAMODB
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_dynamodb_table" "inscripciones_table" {
  name           = "Inscripciones"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CLOUDFRONT
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "S3-timbatumbao-static-site"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Timbatumbao static site"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-timbatumbao-static-site"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# S3
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "static_site" {
  bucket = "timbatumbao-static-site"

  tags = {
    Name        = "Timbatumbao static site"
    Environment = "Prod"
  }
}
