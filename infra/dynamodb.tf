resource "aws_dynamodb_table" "inscripciones_table" {
  name         = var.ddb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "InscripcionID"

  attribute {
    name = "InscripcionID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.encryption_key.arn
  }

  tags = {
    Name        = var.ddb_table_name
    Environment = var.stage
    Service     = "Inscripciones"
  }
}

data "aws_caller_identity" "current" {}