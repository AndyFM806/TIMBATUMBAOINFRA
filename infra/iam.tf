##############################################
# IAM ROLES — ADMIN & SECRETARY (TTApp)
##############################################

##############################################
# ADMIN ROLE (acceso total: Lambdas backend)
##############################################

resource "aws_iam_role" "admin_role_ttapp" {
  name = "AdminRole-TTApp"

  # Lambda asume este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Política principal del rol Admin (acceso total)
resource "aws_iam_role_policy" "admin_policy_ttapp" {
  name = "AdminPolicy-TTApp"
  role = aws_iam_role.admin_role_ttapp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

##############################################
# PERMISO ADICIONAL: InitialLambda → SQS
##############################################

resource "aws_iam_role_policy" "lambda_initial_sqs_policy" {
  name = "LambdaInitialSQSPolicy-TTApp"
  role = aws_iam_role.admin_role_ttapp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Enviar mensajes a SQS
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.payment_queue.arn
      },

      # CloudWatch logs (todas las Lambdas lo necesitan)
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

##############################################
# SECRETARY ROLE (permisos limitados)
##############################################

resource "aws_iam_role" "secretary_role_ttapp" {
  name = "SecretaryRole-TTApp"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "secretary_policy_ttapp" {
  name = "SecretaryPolicy-TTApp"
  role = aws_iam_role.secretary_role_ttapp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ###############################
      # LECTURA LIMITADA EN S3
      ###############################
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.website_bucket.arn,
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
      },

      ###############################
      # LAMBDAS PERMITIDAS
      ###############################
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = [
          "arn:aws:lambda:us-east-1:*:function:UploadVoucher*",
          "arn:aws:lambda:us-east-1:*:function:inscripcionesLambda*"
        ]
      },

      ###############################
      # ACCESO LIMITADO A RDS (solo lectura / conexión)
      ###############################
      {
        Effect   = "Allow"
        Action   = ["rds-db:connect"]
        Resource = "*"
      },

      ###############################
      # SES LIMITADO
      ###############################
      {
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "*"
      },

      ###############################
      # CLOUDWATCH (solo lectura)
      ###############################
      {
        Effect   = "Allow"
        Action   = [
          "logs:GetLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}
