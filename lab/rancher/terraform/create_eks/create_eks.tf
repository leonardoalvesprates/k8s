resource "rancher2_cluster" "eks_create_01" {
  name = "createeks01"
  description = "lprates lab environment"
  eks_config_v2 {
    cloud_credential_id = rancher2_cloud_credential.aws.id
    name = var.aws_eks_name
    region = var.aws_region
    imported = false
    public_access = true
    kubernetes_version = "1.21"
    kms_key = "f278a40e-be26-431c-b939-9608749ed85e"
    # kms_key = "alias/lprates-lab-mar-9-t3"
    # kms_key = aws_kms_key.kms01.key_id
    # kms_key = aws_kms_alias.kms_alias01.name
    secrets_encryption = true
    node_groups {
      name = "ng01"
    }
  }
}