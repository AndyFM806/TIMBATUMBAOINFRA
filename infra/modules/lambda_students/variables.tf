variable "project"         { type = string }
variable "env"             { type = string }
variable "artifact_path"   { type = string }
variable "lambda_role_arn" { type = string }

variable "runtime" {
  type    = string
  default = "java11"
}

variable "handler" {
  type    = string
  default = "com.academia.students.Handler::handleRequest"
}

variable "publish" {
  type    = bool
  default = true
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "layers" {
  type    = list(string)
  default = []
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "use_vpc" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}
