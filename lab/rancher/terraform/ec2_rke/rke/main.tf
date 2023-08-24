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
  kubernetes_version = "v1.24.13-rancher2-2"
  nodes {
    address = file("instance_1_ip")
    hostname_override = "ecw1"
    user    = "ubuntu"
    role    = ["controlplane", "worker", "etcd"]
    ssh_key = file("private_key_ssh.pem")
    ssh_agent_auth = true
  }
  nodes {
    address = file("instance_2_ip")
    hostname_override = "ecw2"
    user    = "ubuntu"
    role    = ["controlplane", "worker", "etcd"]
    ssh_key = file("private_key_ssh.pem")
    ssh_agent_auth = true
  }
  nodes {
    address = file("instance_3_ip")
    hostname_override = "ecw3"
    user    = "ubuntu"
    role    = ["controlplane", "worker", "etcd"]
    ssh_key = file("private_key_ssh.pem")
    ssh_agent_auth = true
  }
}
