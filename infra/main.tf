
provider "aws" {
  region = var.aws_region
}

# --------------------------------------------------------------------
# DATA
# --------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --------------------------------------------------------------------
# NETWORKING
# --------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "tapp-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "tapp-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_region}b"
  tags = {
    Name = "tapp-private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "tapp-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "tapp-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "tapp-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "tapp-nat-gw"
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "tapp-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Grupo de seguridad para el VPC Endpoint de CloudWatch
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Allow TLS traffic for VPC endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

# VPC Endpoint para CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "logs-vpc-endpoint"
  }
}


# --------------------------------------------------------------------
# S3 & CLOUDFRONT
# --------------------------------------------------------------------
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "timbatumbao-frontend-bucket"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-timbatumbao-frontend"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-timbatumbao-frontend"

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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# --------------------------------------------------------------------
# KMS
# --------------------------------------------------------------------
resource "aws_kms_key" "encryption_key" {
  description             = "KMS key for Timbatumbao application"
  deletion_window_in_days = 7
}

# --------------------------------------------------------------------
# IAM ROLES
# --------------------------------------------------------------------
resource "aws_iam_role" "flow_logs_role" {
  name = "tapp-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# --------------------------------------------------------------------
# CLOUDWATCH
# --------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "tapp-vpc-flow-logs"
  retention_in_days = 7
}

resource "aws_flow_log" "main" {
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
}

# --------------------------------------------------------------------
# WAF
# --------------------------------------------------------------------
resource "aws_wafv2_web_acl" "api_gateway_waf" {
  name        = "tapp-waf-acl"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "tapp-waf-metrics"
    sampled_requests_enabled   = true
  }
}
# --------------------------------------------------------------------
# COGNITO
# --------------------------------------------------------------------
resource "aws_cognito_user_pool" "user_pool" {
  name = "TimbatumbaoUsers"
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name = "TimbatumbaoAppClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# --------------------------------------------------------------------
# SES
# --------------------------------------------------------------------
resource "aws_ses_domain_identity" "timbatumbao_domain" {
  domain = "timbatumbao.com"
}
# --------------------------------------------------------------------
# LAMBDAS
# --------------------------------------------------------------------

module "inscripciones_lambda" {
  source = "./modules/inscripcionesLambda"

  lambda_function_name = "InscripcionesFunction"
  lambda_handler       = "com.academiabaile.backend.handlers.InscripcionHandler::handleRequest"
  jar_path             = "../App/backend/academia-baile-backend/target/inscripciones.jar"
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
  lambda_handler       = "com.academiabaile.backend.handlers.PaymentProcessorHandler"
  jar_path             = "../App/backend/academia-baile-backend/target/inscripciones.jar"
  stage                = "prod"
  aws_region           = var.aws_region
  ddb_table_name       = aws_dynamodb_table.inscripciones_table.name
  sns_topic_arn        = module.timbatumbao_resources.sns_topic_arn
  sqs_queue_arn        = aws_sqs_queue.inscripciones_queue.arn
  kms_key_arn          = module.timbatumbao_resources.kms_key_arn
  vpc_id               = aws_vpc.main.id
  subnet_ids           = [aws_subnet.private.id]
}

module "lambda_notificaciones" {
  source = "./modules/lambda_notificaciones"

  lambda_function_name = "Notifier"
  lambda_handler       = "com.academiabaile.backend.handlers.NotificationHandler"
  jar_path             = "../App/backend/academia-baile-backend/target/inscripciones.jar"
  stage                = "prod"
  aws_region           = var.aws_region
  sns_topic_arn        = module.timbatumbao_resources.sns_topic_arn
  kms_key_arn          = module.timbatumbao_resources.kms_key_arn
  vpc_id               = aws_vpc.main.id
  subnet_ids           = [aws_subnet.private.id]
}


# --------------------------------------------------------------------
# API GATEWAY
# --------------------------------------------------------------------

module "api" {
  source = "./modules/api"

  api_name          = "tapp-http-api-inscripciones"
  lambda_invoke_arn = module.inscripciones_lambda.lambda_function_arn
  stage_name        = "prod"
}

# --------------------------------------------------------------------
# TIMBATUMBAO RESOURCES
# --------------------------------------------------------------------

module "timbatumbao_resources" {
  source = "./modules/timbatumbao_resources"

  aws_region  = var.aws_region
  environment = "dev"
}
