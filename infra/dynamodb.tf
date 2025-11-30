resource "aws_dynamodb_table" "inscripciones_table" {
  # El nombre se toma de la variable 'ddb_table_name' que ya usa en terraform.tfvars
  name             = var.ddb_table_name
  # Se recomienda 'PAY_PER_REQUEST' (On-Demand) para serverless.
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "InscripcionID"

  # Definición de atributos de la llave primaria
  attribute {
    name = "InscripcionID"
    type = "S" # S = String, N = Number, B = Binary
  }

  # --- Mejores Prácticas ---
  
  # Habilitar Point-in-Time Recovery (PITR) para backups continuos
  point_in_time_recovery {
    enabled = true
  }

  # Encriptación en reposo
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.ddb_table_name
    Environment = var.stage
    Service     = "Inscripciones"
  }
}