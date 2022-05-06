resource "rancher2_cluster" "rke_ec2" {
  name = var.rke_cluster_name
  description = "lprates lab"
  rke_config {
    kubernetes_version = "v1.19.16-rancher1-5"
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