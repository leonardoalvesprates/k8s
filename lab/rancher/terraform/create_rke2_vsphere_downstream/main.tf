resource "rancher2_machine_config_v2" "machine" {
  generate_name = "${var.prefix}-${random_string.random.result}"
  # https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/machine_config_v2#vsphere_config
  vsphere_config {
    cloudinit = 
    datacenter =
    network = 
    ssh_password = 
    vcenter = 
  }
}

resource "rancher2_cluster_v2" "rke2_cluster" {
  name                                     = "${var.prefix}-${random_string.random.result}"
  kubernetes_version                       = var.kubernetes_version  
  enable_network_policy                    = false
  local_auth_endpoint {
    enabled = true
    fqdn = lablab.prateslabs.com.br
    ca_certs = <<EOF
-----BEGIN CERTIFICATE-----
....
-----END CERTIFICATE-----
EOF
  }
  rke_config {
    machine_pools {
      name                         = "pool1"
      cloud_credential_secret_name = rancher2_cloud_credential.vsphere.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = false
      quantity                     = 3
      machine_config {
        kind = rancher2_machine_config_v2.machine.kind
        name = rancher2_machine_config_v2.machine.name
      }
    }
    machine_pools {
      name                         = "pool2"
      cloud_credential_secret_name = rancher2_cloud_credential.vsphere.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = 3
      machine_config {
        kind = rancher2_machine_config_v2.machine.kind
        name = rancher2_machine_config_v2.machine.name
      }
    }
    machine_global_config = <<EOF
---
cni: cilium
EOF
  }
}
