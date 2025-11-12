# ============================================
# IAM ROLES — ADMIN & SECRETARY (TTApp)
# ============================================

# 🔹 ADMIN ROLE (acceso total)
resource "aws_iam_role" "admin_role_ttapp" {
  name = "AdminRole-TTApp"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

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

# 🔹 SECRETARY ROLE (lectura y ejecución limitada)
resource "aws_iam_role" "secretary_role_ttapp" {
  name = "SecretaryRole-TTApp"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
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
      # Lectura limitada en S3
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.website_bucket.arn,
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
      },
      # Ejecución de Lambdas específicas
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = [
          "arn:aws:lambda:us-east-1:*:function:UploadVoucher*",
          "arn:aws:lambda:us-east-1:*:function:inscripcionesLambda*"
        ]
      },
      # Lectura en RDS vía Proxy (ejemplo)
      {
        Effect   = "Allow"
        Action   = ["rds-db:connect"]
        Resource = "*"
      },
      # Envío limitado de correos (SES)
      {
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "*"
      },
      # Lectura básica de CloudWatch
      {
        Effect   = "Allow"
        Action   = ["logs:GetLogEvents", "logs:DescribeLogStreams"]
        Resource = "*"
      }
    ]
  })
}
