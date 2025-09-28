# Data source para crear el ZIP del Lambda
data "archive_file" "lambda_users" {
  type        = "zip"
  source_dir  = "${path.module}/../users"
  output_path = "${path.module}/bin/users.zip"
}

# IAM Role para Users Lambda
resource "aws_iam_role" "lambda_users_exec_role" {
  name = "${var.project_name}-users-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  tags = var.common_tags
}

# Grupo de logs con retención configurable
resource "aws_cloudwatch_log_group" "users_logs" {
  name              = "/aws/lambda/${var.project_name}-users"
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = var.common_tags
}

# Política para CloudWatch Logs
resource "aws_iam_policy" "users_logs_policy" {
  name        = "${var.project_name}-users-logs-policy"
  description = "Permisos para CloudWatch Logs de Users"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect   = "Allow",
      Resource = [
        "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-users:*"
      ]
    }]
  })
}

# Política para RDS Proxy y Secrets Manager
resource "aws_iam_policy" "users_rds_policy" {
  name        = "${var.project_name}-users-rds-policy"
  description = "Permisos para RDS Proxy y Secrets Manager de Users"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds-db:connect"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:rds-db:${var.aws_region}:*:dbuser:${var.db_proxy_name}/*"
        ]
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect = "Allow",
        Resource = [
          var.db_secret_arn
        ]
      }
    ]
  })
}

# Lambda function Users
resource "aws_lambda_function" "users" {
  function_name    = "${var.project_name}-users"
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_users_exec_role.arn
  filename         = data.archive_file.lambda_users.output_path
  source_code_hash = data.archive_file.lambda_users.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  
  # Configuración de VPC para acceder a RDS
  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = [aws_security_group.lambda_users_sg.id]
  }
  
  environment {
    variables = {
      DB_PROXY_ENDPOINT = var.db_proxy_endpoint
      DB_SECRET_ARN     = var.db_secret_arn
      DB_NAME           = var.db_name
      LOG_LEVEL         = var.log_level
    }
  }
  
  tags       = var.common_tags
  depends_on = [
    aws_cloudwatch_log_group.users_logs,
    aws_iam_role_policy_attachment.users_logs_attach,
    aws_iam_role_policy_attachment.users_rds_attach
  ]
}

# Security Group para Lambda
resource "aws_security_group" "lambda_users_sg" {
  name        = "${var.project_name}-users-lambda-sg"
  description = "Security group para Lambda Users"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla específica para conectar a RDS (puerto 5432 para PostgreSQL o 3306 para MySQL)
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-users-lambda-sg"
  })
}

# Attachments para Users
resource "aws_iam_role_policy_attachment" "users_logs_attach" {
  role       = aws_iam_role.lambda_users_exec_role.name
  policy_arn = aws_iam_policy.users_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "users_rds_attach" {
  role       = aws_iam_role.lambda_users_exec_role.name
  policy_arn = aws_iam_policy.users_rds_policy.arn
}

resource "aws_iam_role_policy_attachment" "users_basic_execution" {
  role       = aws_iam_role.lambda_users_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política adicional para VPC (necesaria cuando Lambda está en VPC)
resource "aws_iam_role_policy_attachment" "users_vpc_execution" {
  role       = aws_iam_role.lambda_users_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}