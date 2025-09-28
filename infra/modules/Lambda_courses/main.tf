# Configuración del proveedor de AWS
provider "aws" {
  region = var.region
}

# Variables locales para nombres y configuraciones
locals {
  name = "${var.project}-${var.env}-courses"
}

# Creación del archivo .zip para la función Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "${path.module}/../src_dist" # Directorio con el código y las dependencias
  output_path = "${path.module}/${var.lambda_zip_file}"
}

# Rol de IAM para la función Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${local.name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# --- Políticas de IAM --- 

# Permiso para logs en CloudWatch
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${local.name}-logging-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      }
    ]
  })
}

# Permiso para leer el secreto de la base de datos
resource "aws_iam_role_policy" "secrets_manager_read" {
  name = "${local.name}-secrets-manager-read-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue",
        Effect   = "Allow",
        Resource = var.db_secret_arn
      }
    ]
  })
}

# Permiso para operar dentro de la VPC
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# --- Recursos Principales ---

# Grupo de logs en CloudWatch
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
}

# Creación de la función Lambda
resource "aws_lambda_function" "this" {
  function_name    = local.name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler" # <-- CAMBIO A JAVASCRIPT
  runtime          = "nodejs20.x"    # <-- CAMBIO A JAVASCRIPT
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30
  memory_size      = 512

  dynamic "vpc_config" {
    for_each = var.use_vpc ? [1] : []
    content {
      subnet_ids         = var.private_subnets
      security_group_ids = var.security_groups
    }
  }

  environment {
    variables = merge(
      var.env_vars,
      {
        DB_SECRET_ARN = var.db_secret_arn
      }
    )
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

# --- API Gateway --- 

# (El código de API Gateway no cambia)
resource "aws_apigatewayv2_api" "this" {
  name          = local.name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.this.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /courses"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvokeCourses"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}