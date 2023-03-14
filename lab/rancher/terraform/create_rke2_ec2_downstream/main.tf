resource "rancher2_machine_config_v2" "machine" {
  generate_name = "${var.prefix}-${random_string.random.result}"
  amazonec2_config {
    ami            = data.aws_ami.ubuntu.id
    region         = var.aws_region
    instance_type  = var.aws_instance_type
    security_group = [var.aws_nsg]
    subnet_id      = var.aws_subnet
    vpc_id         = var.aws_vpc
    zone           = var.aws_zone
    root_size      = "50"
    iam_instance_profile = var.iam_profile
  }
}

resource "rancher2_cluster_v2" "rke2_cluster" {
  name                                     = "${var.prefix}-${random_string.random.result}"
  kubernetes_version                       = var.kubernetes_version  
  enable_network_policy                    = false
  local_auth_endpoint {
    enabled = true
  }
  depends_on = [
    rancher2_cloud_credential.aws
  ]
  rke_config {
    machine_pools {
      name                         = "cp"
      cloud_credential_secret_name = rancher2_cloud_credential.aws.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = false
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.machine.kind
        name = rancher2_machine_config_v2.machine.name
      }
    }
    machine_pools {
      name                         = "wk"
      cloud_credential_secret_name = rancher2_cloud_credential.aws.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.machine.kind
        name = rancher2_machine_config_v2.machine.name
      }
    }
    machine_global_config = <<EOF
---
cni: cilium
disable:
  - rke2-ingress-nginx
  - rke2-metrics-server
EOF
  }
}
