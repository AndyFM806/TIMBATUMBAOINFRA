############################################
# SQS: Cola principal + DLQ (dead-letter)
############################################

# Cola de errores (DLQ)
resource "aws_sqs_queue" "inscripciones_dlq" {
  name                        = "${var.sqs_queue_name}-dlq"
  message_retention_seconds   = 1209600   # 14 días (máximo) para investigación
}

# Cola principal
resource "aws_sqs_queue" "inscripciones_queue" {
  name                               = var.sqs_queue_name

  # Long polling para ahorrar costos y reducir latencia
  receive_wait_time_seconds          = 10

  # Mantén mensajes hasta 4 días si nadie los consume
  message_retention_seconds          = 345600

  # Debe ser >= 6x el timeout de la Lambda (regla recomendada)
  # Tu Lambda tiene timeout 15s -> 6 * 15 = 90
  visibility_timeout_seconds         = 90

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inscripciones_dlq.arn
    maxReceiveCount     = 5   # a la 5ta falla, el mensaje va a la DLQ
  })

  tags = {
    Service     = "Inscripciones"
    Environment = var.stage
  }
}

############################################
# Permisos IAM para que la Lambda lea SQS
############################################

# Adjunta la política administrada: incluye SQS + CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_sqs_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

############################################
# Conectar SQS -> Lambda (Event Source Mapping)
############################################
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn                         = aws_sqs_queue.inscripciones_queue.arn
  function_name                            = aws_lambda_function.inscripciones.arn

  # Ajustes de consumo
  batch_size                               = 5     # mensajes por lote (máx. 10 para SQS)
  maximum_batching_window_in_seconds       = 5     # junta mensajes hasta 5s antes de invocar
  enabled                                  = true

  # Reintentos controlados por SQS (maxReceiveCount en redrive_policy).
}

############################################
# Variables y outputs
############################################
variable "sqs_queue_name" {
  description = "Nombre de la cola SQS principal"
  type        = string
  default     = "inscripciones-queue"
}

output "sqs_queue_url" {
  value = aws_sqs_queue.inscripciones_queue.url
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.inscripciones_queue.arn
}

output "sqs_dlq_url" {
  value = aws_sqs_queue.inscripciones_dlq.url
}
