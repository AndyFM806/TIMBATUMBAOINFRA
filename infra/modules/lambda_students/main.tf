resource "aws_lambda_function" "this" {
  function_name  = "${var.project}-${var.env}-students"
  role           = var.lambda_role_arn
  runtime        = var.runtime
  handler        = var.handler
  filename       = var.artifact_path
  publish        = var.publish
  timeout        = var.timeout
  memory_size    = var.memory_size
  layers         = var.layers

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.use_vpc ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "concurrency" {
  function_name               = aws_lambda_function.this.function_name
  maximum_retry_attempts      = 2
  maximum_event_age_in_seconds = 3600
}
