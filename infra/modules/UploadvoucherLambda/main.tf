resource "aws_lambda_function" "this" {
  function_name    = "${var.project}-${var.env}-uploadVoucher"
  role             = var.lambda_role_arn
  runtime          = "java21"
  handler          = "UploadvoucherLambda::handleRequest"
  filename         = var.artifact_path
  source_code_hash = filebase64sha256(var.artifact_path)
  timeout          = 30
  memory_size      = 1024

  environment {
    variables = var.env_vars
  }

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_lambda_permission" "s3_invoke" {
  count         = var.s3_bucket_arn != "" ? 1 : 0
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "events" {
  count  = var.s3_bucket_name != "" ? 1 : 0
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = var.s3_events
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
