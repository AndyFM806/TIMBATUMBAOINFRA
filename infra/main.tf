terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Puedes cambiar la región si lo necesitas
}

module "timbatumbao_resources" {
  source = "./modules/timbatumbao_resources"

  sqs_queue_name = var.sqs_queue_name
}
