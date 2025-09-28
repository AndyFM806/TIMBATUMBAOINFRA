output "api_invoke_url" {
  value = "https://${module.api_gw.rest_api_id}.execute-api.${var.region}.amazonaws.com/${var.env}"
}
output "students_lambda_name" { value = module.lambda_students.name }
