
# Creacion del S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = "wdc-my-website-bucket"  
## Nombre del bucket. Si se omite, Terraform asignará un nombre aleatorio y único.

  tags = {
    Name        = "My Website Bucket"
    Environment = "Dev"
  }
}
# Configuracion S3 bucket ownership controls
# aws_s3_bucket_ownership_controls Para buscar la documentación oficial de este recurso
# visita: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
    #Ejemplo: Yo como propietario del bucket y otro usuario carga objetos dentro de él, con la regla BucketOwnerPreferred esos objetos pasan automáticamente a ser de mi propiedad como dueño del bucket
  }
}

# Configuracion S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  # Evita que se apliquen ACLs públicas (Access Control Lists) a objetos o al bucket.
  block_public_policy     = false
  # Bloquea políticas de bucket que permitan acceso público.
  ignore_public_acls      = false
  # Ignora cualquier ACL pública existente en objetos.
  restrict_public_buckets = false
  # Restringe el acceso a buckets con políticas públicas.
}
# aws_s3_bucket_public_access_block Para buscar la documentación oficial de este recurso
# visita: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block


# aws_s3_bucket_public_access_block Para buscar la documentación oficial de este recurso
# visita: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl

# Subida de archivos estáticos del frontend al bucket S3
resource "aws_s3_object" "website_bucket" {
  for_each = fileset("${path.module}/../frontend", "**/*")

  bucket = aws_s3_bucket.website_bucket.bucket
  key    = each.value
  source = "${path.module}/../frontend/${each.value}"
  etag   = filemd5("${path.module}/../frontend/${each.value}")

  # Detecta y asigna automáticamente el content-type según la extensión
  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      png  = "image/png"
      jpg  = "image/jpeg"
      jpeg = "image/jpeg"
      svg  = "image/svg+xml"
    },
    regex("\\.(\\w+)$", each.value)[0],
    "application/octet-stream"
  )
}

