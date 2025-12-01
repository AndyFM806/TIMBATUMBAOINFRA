# Role and policy for the Notifier Lambda
resource "aws_iam_role" "lambda_role" {
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

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:us-east-1:*:*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/${var.function_name}:*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Package the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/${var.function_name}.zip"
}

# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = "${trimsuffix(basename(var.source_file), ".py")}.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  kms_key_arn = var.kms_key_arn

  depends_on = [aws_iam_role_policy.lambda_policy]
}
