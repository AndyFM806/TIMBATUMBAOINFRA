variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "artifact_path" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "env_vars" {
  type = map(string)
  default = {}
}

variable "s3_bucket_name" {
  type    = string
  default = ""
}

variable "s3_bucket_arn" {
  type    = string
  default = ""
}

variable "s3_events" {
  type    = list(string)
  default = []
}
