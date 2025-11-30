##############################################
# Rutas locales dentro del módulo
##############################################
locals {
  lambda_zip_abs = abspath(var.lambda_zip_path)
}

data "aws_caller_identity" "current" {}

##############################################
# IAM Role para Lambda sendSms
##############################################
resource "aws_iam_role" "lambda_send_sms_role" {
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

# Logs
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_send_sms_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permiso para escribir en DynamoDB
resource "aws_iam_policy" "ddb_policy" {
  name = "lambda-${var.lambda_function_name}-ddb-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.ddb_table_name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.lambda_send_sms_role.name
  policy_arn = aws_iam_policy.ddb_policy.arn
}

##############################################
# Lambda sendSms
##############################################
resource "aws_lambda_function" "send_sms" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_send_sms_role.arn
  handler       = var.lambda_handler
  runtime       = var.runtime

  filename         = local.lambda_zip_abs
  source_code_hash = filebase64sha256(local.lambda_zip_abs)

  timeout     = 10
  memory_size = 256

  environment {
    variables = {
      STAGE     = var.stage
      DDB_TABLE = var.ddb_table_name
    }
  }

  tags = {
    Service     = "Notificaciones"
    Environment = var.stage
  }
}
