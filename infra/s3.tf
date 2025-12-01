resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "timbatumbao-frontend-bucket"

  tags = {
    Name        = "timbatumbao-frontend-bucket"
    Environment = var.stage
    Service     = "Frontend"
  }
}
