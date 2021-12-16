provider "rancher2" {
  api_url    = "https://lprates-lab.support.rancher.space"
  access_key = var.rancher2_access_key
  secret_key = var.rancher2_secret_key
  bootstrap = false
}