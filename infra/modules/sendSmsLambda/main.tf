##############################################
# Rutas locales dentro del módulo
##############################################
locals {
  lambda_zip_path = "${path.module}/python/sendSms.zip"
}

##############################################
# IAM Role para Lambda sendSms
##############################################

resource "aws_iam_role" "lambda_send_sms_role" {
  name = "lambda-${var.lambda_function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_send_sms_basic_logs" {
  role       = aws_iam_role.lambda_send_sms_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_send_sms_ses_policy" {
  name = "lambda-${var.lambda_function_name}-ses-policy"
  role = aws_iam_role.lambda_send_sms_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

##############################################
# Lambda sendSms
##############################################

resource "aws_lambda_function" "send_sms" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_send_sms_role.arn
  handler       = var.lambda_handler
  runtime       = var.runtime

  filename         = local.lambda_zip_path
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  timeout     = 10
  memory_size = 256

  environment {
    variables = {
      STAGE = var.stage
    }
  }

  tags = {
    Service     = "Notificaciones"
    Environment = var.stage
  }
}
