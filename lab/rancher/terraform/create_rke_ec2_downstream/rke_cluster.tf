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
    }
    ingress {
      default_backend = "false"
    }
  }
  cluster_auth_endpoint {}
}