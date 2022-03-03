resource "rancher2_node_template" "rke_downstream" {
  name = var.rke_cluster_name
  description = "lprates lab"
  amazonec2_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    ami = var.aws_ami
    region = var.aws_region
    security_group = [var.aws_nsg]
    subnet_id = var.aws_subnet
    vpc_id = var.aws_vpc
    zone = var.aws_region
  }
}



