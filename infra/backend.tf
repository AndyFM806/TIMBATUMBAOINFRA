terraform {
  backend "s3" {
    bucket         = "educapp-tfstate-dev"   # <- cambia por tu bucket de estado
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "educapp-tf-locks"
    encrypt        = true
  }
}
