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
  depends_on = [
    rancher2_cloud_credential.aws
  ]
  rke_config {
    machine_pools {
      name                         = "all"
      cloud_credential_secret_name = rancher2_cloud_credential.aws.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = true
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.machine.kind
        name = rancher2_machine_config_v2.machine.name
      }
    }
    machine_selector_files {
      machine_label_selector {
        match_labels = {
          "rke.cattle.io/control-plane-role" = "true"
        }
      }
      file_sources {
        secret {
          name = "config-file-v1"
          default_permissions = "644"
          items {
            dynamic = "true"
            key = "audit-policy"
            path ="/etc/rancher/rke2/custom/policy-v1.yaml"
            permissions = "666"
          }
        }
      }
    }
  }
}


# e.g.

# resource "rancher2_cluster_role_template_binding" "foo" {
#   name = "foo"
#   cluster_id = rancher2_cluster_v2.rke2_cluster.cluster_v1_id
#   role_template_id = "cluster-owner"
#   user_id = "u-6tbbk"
# }
