resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project}-${var.env}-api"
  description = "REST API for ${var.project}"
}

# Authorizer Cognito
resource "aws_api_gateway_authorizer" "cognito_auth" {
  name          = "cognito-${var.env}"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

# Recurso base + /users ... etc
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users"
}
# GET /users -> UsersLambda
resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
}
resource "aws_api_gateway_integration" "users_get_integ" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_get.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = var.users_lambda_arn
}

# Idem para /courses, /students, /uploadvoucher, /inscriptions, /payments (voy a mostrar uno más y replicas)
resource "aws_api_gateway_resource" "students" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "students"
}
resource "aws_api_gateway_method" "students_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
}
resource "aws_api_gateway_integration" "students_post_integ" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.students.id
  http_method = aws_api_gateway_method.students_post.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = var.students_lambda_arn
}

# Deploy + Stage
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers    = { redeploy = timestamp() }
  depends_on  = [
    aws_api_gateway_integration.users_get_integ,
    aws_api_gateway_integration.students_post_integ
  ]
}
resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
  stage_name    = var.env
}

# (Opcional) API Key
resource "aws_api_gateway_api_key" "key" {
  name = "${var.project}-${var.env}-apikey"
  enabled = true
}
