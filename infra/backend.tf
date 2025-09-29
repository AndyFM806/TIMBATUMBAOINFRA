terraform {
  backend "s3" {
    bucket  = "mi-bucket-tfstate"
    key     = "infra/terraform.tfstate"
    region  = "us-east-2"
    profile = "diego"
  }
}