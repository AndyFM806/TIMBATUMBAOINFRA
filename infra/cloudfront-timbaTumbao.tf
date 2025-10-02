# ==============================
# CloudFront + OAI + Certificado
# ==============================

# Origin Access Identity (para que CloudFront acceda al S3 sin hacerlo público)
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for S3 website bucket"
}

# Bucket Policy (dar permisos a CloudFront OAI)
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# Certificado ACM (para HTTPS con dominio propio, ej. "thumbnailcritique.com")
# ⚠️ Importante: Debe crearse en us-east-1 porque CloudFront solo acepta certificados en esa región
resource "aws_acm_certificate" "cloudfront" {
  domain_name       = "thumbnailcritique.com" # Cámbialo por tu dominio real
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validación del certificado ACM
resource "aws_acm_certificate_validation" "cloudfront" {
  certificate_arn = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.resource_record_name
  ]
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  # Si aún no tienes dominio, comenta esta parte (aliases) y usa solo el domain_name que da CloudFront
  aliases = ["thumbnailcritique.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.cloudfront]
}

# ===================
# Outputs útiles
# ===================
output "s3_bucket_name" {
  value = aws_s3_bucket.website_bucket.bucket
}