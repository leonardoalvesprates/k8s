resource "rancher2_cluster" "rke_ec2" {
  name = var.rke_cluster_name
  description = "rke downstream lab"
  rke_config {
    kubernetes_version = var.kubernetes_version
    network {
      plugin = "canal"
    }
    services {
      etcd {
        creation = "6h"
        retention = "72h"
      }
      # kube_controller {
      #   cluster_cidr = 11.42.0.0/16
      #   service_cluster_ip_range = 11.43.0.0/16
      # }
      # kube_api {
      #   service_cluster_ip_range = 11.43.0.0/16
      # }
    }
    ingress {
      default_backend = "false"
    }
  }
  cluster_auth_endpoint {}
}