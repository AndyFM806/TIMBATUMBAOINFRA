# Rol ejecución Lambda (con logs + VPC)
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project}-${var.env}-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect="Allow", Principal={ Service="lambda.amazonaws.com" }, Action="sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Roles lógicos del negocio (Admin/Secretary) para invocar servicios
resource "aws_iam_role" "admin_role" {
  name = "${var.project}-${var.env}-AdminRole"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{
      Effect="Allow", Principal={ Service="lambda.amazonaws.com" }, Action="sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role" "secretary_role" {
  name = "${var.project}-${var.env}-SecretaryRole"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{
      Effect="Allow", Principal={ Service="lambda.amazonaws.com" }, Action="sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "admin_policy" {
  name   = "${var.project}-${var.env}-AdminPolicy"
  policy = file("${path.module}/policies/admin.json")
}
resource "aws_iam_policy" "secretary_policy" {
  name   = "${var.project}-${var.env}-SecretaryPolicy"
  policy = file("${path.module}/policies/secretary.json")
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.admin_policy.arn
}
resource "aws_iam_role_policy_attachment" "secretary_attach" {
  role       = aws_iam_role.secretary_role.name
  policy_arn = aws_iam_policy.secretary_policy.arn
}
