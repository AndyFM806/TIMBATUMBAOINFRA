variable "project" { type = string }
variable "env"     { type = string }      # dev|qa|prod
variable "region"  { type = string }
variable "profile" {
  type    = string
  default = ""
}

# Ruta al JAR de StudentsLambda (compilado con Maven)
variable "students_artifact" { type = string }
