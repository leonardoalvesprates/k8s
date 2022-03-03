resource "rancher2_node_template" "rke_template" {
  name = var.rke_node_template_name
  description = "lprates lab"
  amazonec2_config {
    #access_key = var.aws_access_key
    #secret_key = var.aws_secret_key
    cloud_credential_id = rancher2_cloud_credential.aws.id
    ami = var.aws_ami
    region = var.aws_region
    security_group = [var.aws_nsg]
    subnet_id = var.aws_subnet
    vpc_id = var.aws_vpc
    zone = var.aws_region
    instance_type = var.aws_instance_type
    root_size = "30"
    #zone = var.aws_zone
  }
}



