resource "rancher2_cloud_credential" "aws" {
  name = "${var.prefix}-${random_string.random.result}"
  amazonec2_credential_config {
    access_key     = var.aws_access_key
    secret_key     = var.aws_secret_key
  }
}