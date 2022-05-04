resource "rancher2_cluster" "rke_ec2" {
  name = var.rke_cluster_name
  description = "lprates lab"
  rke_config {
    kubernetes_version = "v1.20.15-rancher1-3"
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