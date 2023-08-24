provider "rke" {
  log_file = "rke_debug.log"
}

terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "1.4.2"
    }
  }
}

resource "rke_cluster" "rke" {
  ignore_docker_version = true
  kubernetes_version = "v1.23.16-rancher2-3"
  cluster_yaml = file("cluster.yml")
}
