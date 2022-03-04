resource "rancher2_node_template" "rke_template" {
  name = var.rke_node_template_name
  description = "lprates lab"
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
    root_size = "30"
    iam_instance_profile = "rk-all-role"
    tags = "Owner,lprates"
    #keypair_name = "leonardo.prates-lab"
    #ssh_user = "ubuntu"
    #ssh_keypath = "./sshkey.pem"
  }
}

resource "rancher2_cluster" "rke_ec2" {
  name = var.rke_cluster_name
  description = "lprates lab"
  rke_config {
    network {
      plugin = "canal"
    }
  }
}

resource "rancher2_node_pool" "cp26" {
  cluster_id =  rancher2_cluster.rke_ec2.id
  name = "cp"
  hostname_prefix = "cp"
  node_template_id = rancher2_node_template.rke_template.id
  quantity = 1
  control_plane = true
  etcd = true
  worker = false
}

resource "rancher2_node_pool" "wk26" {
  cluster_id =  rancher2_cluster.rke_ec2.id
  name = "wk"
  hostname_prefix = "wk"
  node_template_id = rancher2_node_template.rke_template.id
  quantity = 1
  control_plane = false
  etcd = false
  worker = true
}

output "kube_config" {
  value = rancher2_cluster.rke_ec2.kube_config
  description = "kube_config data"
  sensitive = true
}