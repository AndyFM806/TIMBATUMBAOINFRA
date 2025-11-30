resource "aws_lambda_function" "initial_lambda" {
  function_name = "Lambda-Initial"
  role          = aws_iam_role.admin_role_ttapp.arn
  handler       = var.lambda_handler
  runtime       = "python3.12"

  filename         = "${path.module}/../lambda/initial_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/initial_lambda.zip")

  environment {
    variables = {
      STAGE          = var.stage
      PAYMENT_QUEUE  = aws_sqs_queue.payment_queue.url
    }
  }

  tags = {
    Name        = "Lambda-Initial"
    Environment = var.stage
  }
}
