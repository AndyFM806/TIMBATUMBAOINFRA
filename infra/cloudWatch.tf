locals {
  region                  = "us-east-1"
  
  # Referencias a API Gateway (desde el módulo 'api' en modules.tf)
  api_gateway_id          = module.api.api_id
  
  # Referencias a Lambdas (desde lambda_initial.tf, módulos inscripciones/sms)
  lambda_initial_name     = aws_lambda_function.initial_lambda.function_name
  lambda_inscripciones_name = module.inscripciones_lambda.lambda_name
  lambda_sms_name         = module.send_sms_lambda.lambda_name
  
  # Referencia a DynamoDB (se usa la variable global ddb_table_name)
  dynamodb_table_name     = var.ddb_table_name
}


resource "aws_cloudwatch_dashboard" "timbatumbao_observability_dashboard" {
  dashboard_name = "Timbatumbao-Resumen-Observabilidad"
  
  dashboard_body = jsonencode({
    widgets = [
      
      ##################################
      # 1. API Gateway: Latencia y Errores
      ##################################
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", local.api_gateway_id, { "stat": "Average", "label": "Latencia Promedio (ms)" }],
            ["...", "4xxError", "ApiId", local.api_gateway_id, { "stat": "Sum", "label": "Errores 4XX (Cliente)" }],
            ["...", "5xxError", "ApiId", local.api_gateway_id, { "stat": "Sum", "label": "Errores 5XX (Servidor)" }]
          ]
          period = 60
          region = local.region
          title  = "API Gateway HTTP - Salud General"
          yAxis  = { left = { min = 0 } }
        }
      },

      ##################################
      # 2. Resumen de Lambdas (Inscripciones, Initial, sendSms)
      ##################################
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_inscripciones_name, { "stat": "Sum" }],
            ["...", "Invocations", "FunctionName", local.lambda_initial_name, { "stat": "Sum" }],
            ["...", "Invocations", "FunctionName", local.lambda_sms_name, { "stat": "Sum" }],
            ["...", "Errors", "FunctionName", local.lambda_inscripciones_name, { "stat": "Sum" }],
            ["...", "Errors", "FunctionName", local.lambda_initial_name, { "stat": "Sum" }],
            ["...", "Errors", "FunctionName", local.lambda_sms_name, { "stat": "Sum" }]
          ]
          period = 300
          region = local.region
          title  = "Visión General de Lambdas (Invocaciones y Errores)"
          legend = { position = "bottom" }
        }
      },

      ##################################
      # 3. DynamoDB - Uso y Errores
      ##################################
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", local.dynamodb_table_name, { "stat": "Sum", "label": "WCU Consumidas" }],
            ["...", "ConsumedReadCapacityUnits", "TableName", local.dynamodb_table_name, { "stat": "Sum", "label": "RCU Consumidas" }],
            ["...", "UserErrors", "TableName", local.dynamodb_table_name, { "stat": "Sum", "label": "Errores de Usuario (4xx)", "yAxis": "right" }],
          ]
          period = 300
          region = local.region
          title  = "DynamoDB - Tabla: ${local.dynamodb_table_name}"
          yAxis  = { left = { label = "Capacidad Unitaria", min = 0 }, right = { label = "Errores", min = 0 } }
        }
      },
      
      ##################################
      # 4. Lambda Inscripciones - Tiempos y Errores
      ##################################
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_inscripciones_name, { "stat": "Average", "label": "Duración Promedio (ms)" }],
            ["...", "Duration", "FunctionName", local.lambda_inscripciones_name, { "stat": "p95", "label": "Duración P95 (ms)" }],
            ["...", "Errors", "FunctionName", local.lambda_inscripciones_name, { "stat": "Sum", "label": "Errores de Ejecución" }],
            ["...", "Throttles", "FunctionName", local.lambda_inscripciones_name, { "stat": "Sum", "label": "Throttling" }]
          ]
          period = 60
          region = local.region
          title  = "Lambda Inscripciones - Rendimiento"
          yAxis  = { left = { min = 0 }, right = { min = 0 } }
        }
      }
    ]
  })
}