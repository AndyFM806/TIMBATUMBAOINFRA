# infra/lambda_pagos.tf

# 1. Empaquetar el código fuente de la Lambda
data "archive_file" "lambda_pagos_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../App/lambdas/pagos"
  output_path = "${path.module}/../dist/lambda_pagos.zip"
}

# 2. Grupo de Seguridad para la Lambda (permite todo el tráfico de salida)
resource "aws_security_group" "lambda_pagos_sg" {
  name        = "lambda-pagos-sg"
  description = "Permitir todo el tráfico saliente para la Lambda de Pagos"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-pagos-sg"
  }
}

# 3. Definir el Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_pagos_role" {
  name = "lambda-pagos-role"

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

# 4. Adjuntar la política básica de ejecución
resource "aws_iam_role_policy_attachment" "lambda_pagos_basic" {
  role       = aws_iam_role.lambda_pagos_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 5. Adjuntar la política de acceso a la VPC
resource "aws_iam_role_policy_attachment" "lambda_pagos_vpc" {
  role       = aws_iam_role.lambda_pagos_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# 6. Crear la Función Lambda en AWS
resource "aws_lambda_function" "lambda_pagos" {
  function_name = "LambdaPagos"
  role          = aws_iam_role.lambda_pagos_role.arn
  handler       = "main.handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_pagos_zip.output_path
  source_code_hash = data.archive_file.lambda_pagos_zip.output_base64sha256
  timeout          = 30 # Aumentamos el timeout por si la API externa tarda en responder

  # Conectar la Lambda a la VPC y Subred Privada
  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_pagos_sg.id]
  }

  tags = {
    Name = "LambdaPagos"
  }

  # Nos aseguramos de que la NAT Gateway exista antes de crear la Lambda
  depends_on = [aws_nat_gateway.main]
}
