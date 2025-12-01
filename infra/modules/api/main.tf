# API HTTP + CORS
resource "aws_apigatewayv2_api" "http" {
  name          = "tapp-http-api-inscripciones"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type", "authorization"]
  }
}

# CloudWatch Log Group for Access Logs
resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.http.name}/prod"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

# Stage
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "ip" : "$context.identity.sourceIp",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "routeKey" : "$context.routeKey",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength"
    })
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway_access_logs]
}

# Integración Lambda (Inscripciones)
resource "aws_apigatewayv2_integration" "inscripciones" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn
  payload_format_version = "2.0"
}

# Ruta /inscripciones
resource "aws_apigatewayv2_route" "inscripciones" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /inscripciones"
  target    = "integrations/${aws_apigatewayv2_integration.inscripciones.id}"
}

# Permiso APIGW -> Lambda (Inscripciones) - Más seguro
resource "aws_lambda_permission" "apigw_invoke_inscripciones" {
  statement_id  = "AllowAPIGWInvokeInscripciones"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = var.lambda_arn
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/${aws_apigatewayv2_route.inscripciones.route_key}"
}

# --- Integración Lambda (Initial) ---
resource "aws_apigatewayv2_integration" "initial" {
  count = var.enable_initial_route ? 1 : 0

  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_initial_arn
  payload_format_version = "2.0"
}

# Ruta GET /initial
resource "aws_apigatewayv2_route" "initial" {
  count = var.enable_initial_route ? 1 : 0

  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /initial"
  target    = "integrations/${aws_apigatewayv2_integration.initial[0].id}"
}

# Permiso APIGW -> Lambda (Initial)
resource "aws_lambda_permission" "apigw_invoke_initial" {
  count = var.enable_initial_route ? 1 : 0

  statement_id  = "AllowAPIGWInvokeInitial"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = var.lambda_initial_arn
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/${aws_apigatewayv2_route.initial[0].route_key}"
}

# --- Integración Lambda (Pagos) ---
resource "aws_apigatewayv2_integration" "pagos" {
  count = var.enable_pagos_route ? 1 : 0

  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_pagos_arn
  payload_format_version = "2.0"
}

# Ruta POST /pagos
resource "aws_apigatewayv2_route" "pagos" {
  count = var.enable_pagos_route ? 1 : 0

  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /pagos"
  target    = "integrations/${aws_apigatewayv2_integration.pagos[0].id}"
}

# Permiso APIGW -> Lambda (Pagos)
resource "aws_lambda_permission" "apigw_invoke_pagos" {
  count = var.enable_pagos_route ? 1 : 0

  statement_id  = "AllowAPIGWInvokePagos"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = var.lambda_pagos_arn
  source_-arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/${aws_apigatewayv2_route.pagos[0].route_key}"
}
