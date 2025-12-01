# infra/monitoring.tf

resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "TappInscripcionesDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text",
        x      = 0,
        y      = 0,
        width  = 24,
        height = 1,
        properties = {
          markdown = "# Dashboard Principal: Aplicación Tapp de Inscripciones"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 1,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", module.api.api_id, { "label" = "Peticiones Totales", "stat" = "Sum" }],
            [".", "4xx", ".", ".", { "label" = "Errores Cliente (4XX)", "stat" = "Sum" }],
            [".", "5xx", ".", ".", { "label" = "Errores Servidor (5XX)", "stat" = "Sum" }]
          ],
          view   = "timeSeries",
          region = var.aws_region,
          title  = "API Gateway: Peticiones y Errores",
          period = 60
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 1,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", module.api.api_id, { "stat" = "p90", "label" = "Latencia p90" }],
            [".", ".", ".", ".", { "stat" = "p95", "label" = "Latencia p95" }]
          ],
          view   = "timeSeries",
          region = var.aws_region,
          title  = "API Gateway: Latencia",
          period = 60
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 7,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.inscripciones_lambda.lambda_function_name, { "stat" = "Sum", "label" = "Inscripciones (Invocaciones)" }],
            ["AWS/Lambda", "Errors", "FunctionName", module.inscripciones_lambda.lambda_function_name, { "stat" = "Sum", "label" = "Inscripciones (Errores)" }],
            ["AWS/Lambda", "Invocations", "FunctionName", module.lambda_processor.lambda_function_name, { "stat" = "Sum", "label" = "Pagos (Invocaciones)" }],
            ["AWS/Lambda", "Errors", "FunctionName", module.lambda_processor.lambda_function_name, { "stat" = "Sum", "label" = "Pagos (Errores)" }]
          ],
          view   = "timeSeries",
          region = var.aws_region,
          title  = "Lambdas Principales (Invocaciones y Errores)",
          period = 60
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 7,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.lambda_notificaciones.lambda_function_name, { "stat" = "Sum", "label" = "Notificaciones (Invocaciones)" }],
            ["AWS/Lambda", "Errors", "FunctionName", module.lambda_notificaciones.lambda_function_name, { "stat" = "Sum", "label" = "Notificaciones (Errores)" }]
          ],
          view   = "timeSeries",
          region = var.aws_region,
          title  = "Lambdas Auxiliares (Invocaciones y Errores)",
          period = 60
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 13,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", aws_dynamodb_table.inscripciones_table.name, { "stat" = "Sum" }],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.inscripciones_table.name, { "stat" = "Sum" }]
          ],
          view   = "timeSeries",
          region = var.aws_region,
          title  = "DynamoDB: Capacidad Consumida",
          period = 60
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 13,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/SNS", "NumberOfMessagesPublished", "TopicName", "timbatumbao-notifications", { "stat" = "Sum" }]
          ],
          view   = "timeSeries",
          region = var.aws_region,
          title  = "SNS: Notificaciones Publicadas",
          period = 60
        }
      }
    ]
  })
}
