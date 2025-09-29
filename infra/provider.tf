terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "diego"

  default_tags {
    tags = {
      name        = "NotiApp"
      Environment = "Dev"
    }
  }
}
