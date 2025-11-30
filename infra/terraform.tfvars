send_sms_lambda_zip = "${path.module}/lambdas/sendSms/sendSms.zip"

# ─────────────────────────────
# Configuración general
# ─────────────────────────────
aws_region = "us-east-1"
stage      = "Dev"

# Dominios que pueden llamar al API Gateway (CORS)
allowed_origins = [
  "http://localhost:3000", # cámbialo por el real
]

# ─────────────────────────────
# Auth (Cognito)
# ─────────────────────────────
enable_cognito_auth = true

# Reemplaza <region> y <user-pool-id> por los reales
jwt_issuer = "https://cognito-idp.us-east-1.amazonaws.com/<USER_POOL_ID>"

# Reemplaza por el/los App Client ID de tu User Pool
jwt_audiences = [
  "<COGNITO_APP_CLIENT_ID>"
]

# ─────────────────────────────
# Lambda de INSCRIPCIONES (Java)
# ─────────────────────────────
# OJO: estos valores se pasan al módulo "inscripciones_lambda"

lambda_function_name = "inscripcionesLambda"

# Ajusta al handler REAL que tenga tu proyecto Java
# (paquete.ClaseHandler::metodo), NO al service puro.
lambda_handler = "infra.modules.inscripcionesLambda.InscripcionService::inscribirCliente"

# Ruta del JAR visto desde la carpeta infra/
# (tfvars no admite ${path.module}, solo strings)
jar_path = "modules/inscripcionesLambda/java/target/inscripciones.jar"

# Nombre de la tabla DynamoDB que usará la Lambda
ddb_table_name = "InscripcionesTable"

# Nombre de la cola principal de inscripciones
sqs_queue_name = "inscripciones-queue"

# ─────────────────────────────
# CloudFront / Certificado
# ─────────────────────────────
# ARN del certificado ACM en us-east-1 para tu dominio de CloudFront
cloudfront_acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
