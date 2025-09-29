variable "project" { type = string }
variable "env"     { type = string }

variable "cognito_user_pool_arn" { type = string }
variable "users_lambda_arn"        { type = string }
variable "courses_lambda_arn"      { type = string }
variable "students_lambda_arn"     { type = string }
variable "uploadvoucher_lambda_arn" { type = string }
variable "inscriptions_lambda_arn"  { type = string }
variable "payments_lambda_arn"      { type = string }
