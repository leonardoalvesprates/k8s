terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = ">= 1.21.0"
    }
  }
}

provider "rancher2" {
  api_url    = "https://lprates-lab.support.rancher.space"
  token_key = var.rancher2_token_key
  bootstrap = false
}