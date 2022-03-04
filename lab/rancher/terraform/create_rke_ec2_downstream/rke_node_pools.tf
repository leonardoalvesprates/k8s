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