resource "rancher2_node_pool" "cp26" {
  cluster_id =  rancher2_cluster.rke_ec2.id
  name = "${var.prefix}-cp"
  hostname_prefix = "${var.prefix}-cp"
  node_template_id = rancher2_node_template.rke_template.id
  quantity = var.cp_count
  control_plane = true
  etcd = true
  worker = false
}

resource "rancher2_node_pool" "wk26" {
  cluster_id = rancher2_cluster.rke_ec2.id
  name = "${var.prefix}-wk"
  hostname_prefix = "${var.prefix}-wk"
  node_template_id = rancher2_node_template.rke_template.id
  quantity = var.wk_count
  control_plane = false
  etcd = false
  worker = true
}