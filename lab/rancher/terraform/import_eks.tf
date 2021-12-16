resource rancher2_cluster eks_import_01 {
  name = "imported-eks-01"
  description = "lprates lab environment"
  eks_config_v2 {
    cloud_credential_id = rancher2_cloud_credential.aws
    name = "eks-dec16-lab3"
    region = "us-east-1"
    imported = true
  }
}