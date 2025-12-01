variable "processor_function_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "PaymentProcessor"
}

variable "processor_source_file" {
  description = "The path to the Lambda function's source code."
  type        = string
  default     = "../../lambda/payment_processor_lambda.py"
}

variable "payment_queue_arn" {
  description = "The ARN of the SQS queue for payment processing."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for enrollments."
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications."
  type        = string
}

variable "processor_kms_key_arn" {
  description = "The ARN of the KMS key for encrypting environment variables."
  type        = string
}

data "archive_file" "processor_lambda_zip" {
  type        = "zip"
  source_file = var.processor_source_file
  output_path = "${path.module}/${var.processor_function_name}.zip"
}

resource "aws_iam_role" "processor_lambda_exec_role" {
  name = "${var.processor_function_name}-role"

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

resource "aws_iam_policy" "processor_lambda_permissions" {
  name        = "${var.processor_function_name}-policy"
  description = "Permissions for the ${var.processor_function_name} Lambda function."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.payment_queue_arn
      },
      {
        Effect   = "Allow",
        Action   = "dynamodb:PutItem",
        Resource = "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_name}"
      },
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = var.sns_topic_arn
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

resource "aws_iam_role_policy_attachment" "processor_lambda_attach" {
  role       = aws_iam_role.processor_lambda_exec_role.name
  policy_arn = aws_iam_policy.processor_lambda_permissions.arn
}

resource "aws_lambda_function" "processor_this" {
  function_name = var.processor_function_name
  role          = aws_iam_role.processor_lambda_exec_role.arn
  handler       = "payment_processor_lambda.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.processor_lambda_zip.output_path
  source_code_hash = data.archive_file.processor_lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      SNS_TOPIC_ARN       = var.sns_topic_arn
    }
  }

  kms_key_arn = var.processor_kms_key_arn

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name = var.processor_function_name
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.payment_queue_arn
  function_name    = aws_lambda_function.processor_this.arn
  batch_size       = 5 # Process up to 5 messages at a time
}
