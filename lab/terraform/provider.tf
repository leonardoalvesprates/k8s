terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
  bucket     = "labtfstate"
  key        = "tfstate/labk8s.tfstate"
  region     = "us-east-1"
  role_arn   = "arn:aws:iam::931049509788:user/admin"

  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}