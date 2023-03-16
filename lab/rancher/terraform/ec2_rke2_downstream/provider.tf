terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.25.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

  }
}

provider "rancher2" {
  api_url   = var.rancher_url
  token_key = var.rancher2_token_key
  bootstrap = false
  insecure  = true
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
