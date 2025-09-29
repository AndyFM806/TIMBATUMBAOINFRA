variable "project"         { type = string }
variable "env"             { type = string }
variable "vpc_id"          { type = string }
variable "private_subnets" { type = list(string) }
variable "db_username"     { type = string }
variable "db_password"     { type = string sensitive = true }
variable "lambda_sg_id"    { type = string }
