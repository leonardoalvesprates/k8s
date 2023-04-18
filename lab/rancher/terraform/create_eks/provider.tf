terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.22.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "rancher2" {
  api_url    = var.rancher_url
  token_key = var.rancher2_token_key
  bootstrap = false
}

provider "aws" {
  region = "sa-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
