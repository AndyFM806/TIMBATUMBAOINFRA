resource "aws_lambda_function" "students" {
  function_name    = "${var.project}-${var.env}-students"
  role             = var.lambda_role_arn
  runtime          = "java21"
  handler          = "com.timbatumbao.students.StudentsHandler"  # nombre completo de tu clase
  filename         = var.artifact_path
  source_code_hash = filebase64sha256(var.artifact_path)
  timeout          = 30
  memory_size      = 1024

  # variables de entorno si necesitas (ejemplo)
  # environment { variables = { DB_HOST = "..." } }
}
