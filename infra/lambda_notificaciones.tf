# infra/lambda_notificaciones.tf

# 1. Empaquetar el código fuente de la Lambda
data "archive_file" "lambda_notificaciones_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../App/lambdas/notificaciones"
  output_path = "${path.module}/../dist/lambda_notificaciones.zip"
}

# 2. Definir el Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_notificaciones_role" {
  name = "lambda-notificaciones-role"

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

# 3. Adjuntar la política básica de ejecución para logs
resource "aws_iam_role_policy_attachment" "lambda_notificaciones_basic" {
  role       = aws_iam_role.lambda_notificaciones_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4. Crear la Función Lambda en AWS
resource "aws_lambda_function" "lambda_notificaciones" {
  function_name = "LambdaNotificaciones"
  role          = aws_iam_role.lambda_notificaciones_role.arn
  handler       = "main.handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_notificaciones_zip.output_path
  source_code_hash = data.archive_file.lambda_notificaciones_zip.output_base64sha256
  timeout          = 10

  tags = {
    Name = "LambdaNotificaciones"
  }
}

# 5. Suscribir la Lambda al Tema de SNS
resource "aws_sns_topic_subscription" "lambda_notificaciones_subscription" {
  topic_arn = aws_sns_topic.payment_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_notificaciones.arn
}

# 6. Dar permiso a SNS para que invoque la Lambda
resource "aws_lambda_permission" "sns_invoke_lambda" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = aws_lambda_function.lambda_notificaciones.function_name
  source_arn    = aws_sns_topic.payment_notifications.arn
}
