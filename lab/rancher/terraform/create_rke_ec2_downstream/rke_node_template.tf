resource "rancher2_node_template" "rke_template" {
  name = var.rke_node_template_name
  description = "ec2 rke node template"
  cloud_credential_id = rancher2_cloud_credential.aws.id
  engine_install_url = "https://releases.rancher.com/install-docker/20.10.sh"
  amazonec2_config {
    ami = var.aws_ami
    region = var.aws_region
    security_group = [var.aws_nsg]
    subnet_id = var.aws_subnet
    vpc_id = var.aws_vpc
    zone = var.aws_zone
    instance_type = var.aws_instance_type
    root_size = "50"
    iam_instance_profile = var.iam_profile
    tags = "Owner,${var.prefix}"
  }
  depends_on = [
  rancher2_cloud_credential.aws,
  ]
}