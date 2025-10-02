# SQS: DLQ + Cola principal
#############################
variable "sqs_queue_name" {
  description = "cola-principal"
  type        = string
}

resource "aws_sqs_queue" "inscripciones_dlq" {
  name                      = "${var.sqs_queue_name}-dlq"
  message_retention_seconds = 1209600   # 14 días
}

resource "aws_sqs_queue" "inscripciones_queue" {
  name                       = var.sqs_queue_name
  receive_wait_time_seconds  = 10
  message_retention_seconds  = 345600   # 4 días
  visibility_timeout_seconds = 90       # >= 6x timeout Lambda (6*15=90)

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inscripciones_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service     = "Inscripciones"
    Environment = var.stage
  }
}

#############################
# Event Source Mapping SQS -> Lambda
#############################
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn                   = aws_sqs_queue.inscripciones_queue.arn
  function_name                      = aws_lambda_function.inscripciones.arn
  batch_size                         = 5
  maximum_batching_window_in_seconds = 5
  enabled                            = true
}

#############################
# Outputs del módulo
#############################
output "lambda_arn"  { value = aws_lambda_function.inscripciones.arn }
output "lambda_name" { value = aws_lambda_function.inscripciones.function_name }

output "sqs_queue_url" { value = aws_sqs_queue.inscripciones_queue.url }
output "sqs_queue_arn" { value = aws_sqs_queue.inscripciones_queue.arn }
#Producto (web/servicio) envía un mensaje JSON con la inscripción a inscripciones-queue (SQS).
#SQS guarda el mensaje de forma duradera.
#Event Source Mapping (SQS → Lambda) detecta mensajes y dispara la Lambda en lotes de 5 (tu batch_size).
#La Lambda procesa cada inscripción (ej. valida datos, escribe en DynamoDB, etc.).
#Si la Lambda confirma el lote, SQS elimina esos mensajes.
#Si la Lambda falla, SQS reintenta. Tras 5 intentos (tu maxReceiveCount), el mensaje se mueve a la DLQ inscripciones-queue-dlq para análisis posterior.