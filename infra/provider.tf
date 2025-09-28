terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"   # cámbialo si tu región es distinta
  profile = "diego"       # tu perfil de AWS CLI
}
