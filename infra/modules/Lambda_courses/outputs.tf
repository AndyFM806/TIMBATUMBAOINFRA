
# outputs.tf

output "lambda_function_arn" {
  description = "El ARN de la función Lambda creada."
  value       = aws_lambda_function.courses_lambda.arn
}

output "courses_api_url" {
  description = "La URL de la API para acceder a la lista de cursos."
  value       = "${aws_apigatewayv2_stage.courses_stage.invoke_url}/courses"
}
