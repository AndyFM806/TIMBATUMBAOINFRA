locals { name = "${var.project}-${var.env}-inscripciones" }

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "this" {
  function_name    = local.name
  role             = var.lambda_role_arn
  runtime          = "java21"
  handler          = "app.enroll.EnrollHandler::handleRequest"  # <-- tu handler Java
  filename         = var.artifact_path
  source_code_hash = filebase64sha256(var.artifact_path)
  timeout          = 30
  memory_size      = 1024

  dynamic "vpc_config" {
    for_each = var.use_vpc ? [1] : []
    content {
      subnet_ids         = var.private_subnets
      security_group_ids = var.security_groups
    }
  }

  environment { variables = var.env_vars }

  depends_on = [aws_cloudwatch_log_group.this]
}

# Permiso: API Gateway puede invocar el Lambda (cubre TODOS los métodos/rutas del stage)
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvokeInscripciones"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/*"  # ANY method, cualquier recurso
}
