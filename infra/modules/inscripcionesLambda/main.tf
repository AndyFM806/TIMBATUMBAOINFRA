locals {
  # Ruta absoluta al JAR enviada desde el root
  jar_path_abs = abspath(var.jar_path)
}

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------
# IAM ROLE
# ---------------------------------------------------------------------
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-${var.lambda_function_name}-exec-role-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Logs básicos
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permisos mínimos sobre DynamoDB
resource "aws_iam_policy" "ddb_policy" {
  name = "lambda-${var.lambda_function_name}-ddb-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.ddb_table_name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ddb_policy.arn
}

# Permiso para publicar en el topic SNS
resource "aws_iam_policy" "sns_publish_policy" {
  name = "lambda-${var.lambda_function_name}-sns-publish"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_publish_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

# ---------------------------------------------------------------------
# LAMBDA JAVA 17
# ---------------------------------------------------------------------
resource "aws_lambda_function" "inscripciones" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.lambda_handler
  runtime       = "java17"

  filename         = local.jar_path_abs
  source_code_hash = filebase64sha256(local.jar_path_abs)

  timeout     = 15
  memory_size = 512

  environment {
    variables = {
      DDB_TABLE     = var.ddb_table_name
      STAGE         = var.stage
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = {
    Service     = var.lambda_function_name
    Environment = var.stage
  }
}
