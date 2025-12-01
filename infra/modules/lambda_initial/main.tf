variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "EnrollmentRequestHandler"
}

variable "source_file" {
  description = "The path to the Lambda function's source code."
  type        = string
  default     = "../../lambda/initial_lambda.py"
}

variable "payment_queue_url" {
  description = "The URL of the SQS queue for payment processing."
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for encrypting environment variables."
  type        = string
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_permissions" {
  name        = "${var.function_name}-policy"
  description = "Permissions for the ${var.function_name} Lambda function."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sqs:SendMessage",
        Resource = "*" # Simplified for this example, should be queue ARN in prod
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "initial_lambda.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      PAYMENT_QUEUE_URL = var.payment_queue_url
    }
  }

  kms_key_arn = var.kms_key_arn

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name = var.function_name
  }
}
