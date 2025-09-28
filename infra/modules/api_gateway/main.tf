# API REST básico
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.project}-${var.env}-api"
}

# /students/{studentId}/enrollments
resource "aws_api_gateway_resource" "students" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "students"
}
resource "aws_api_gateway_resource" "studentId" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.students.id
  path_part   = "{studentId}"
}
resource "aws_api_gateway_resource" "enrollments" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.studentId.id
  path_part   = "enrollments"
}

# ANY /students/{studentId}/enrollments  -> Lambda proxy
resource "aws_api_gateway_method" "any_enrollments" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.enrollments.id
  http_method   = "ANY"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "proxy_enrollments" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.enrollments.id
  http_method             = aws_api_gateway_method.any_enrollments.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.students_lambda_arn}/invocations"
}

# Permiso para que API GW invoque la Lambda
resource "aws_lambda_permission" "allow_apigw_students" {
  statement_id  = "AllowAPIGatewayInvokeStudents"
  action        = "lambda:InvokeFunction"
  function_name = var.students_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Despliegue y stage
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers    = { redeploy = timestamp() }
  lifecycle { create_before_destroy = true }
}
resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
  stage_name    = var.env
}

output "rest_api_id" { value = aws_api_gateway_rest_api.api.id }
