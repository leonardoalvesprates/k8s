resource "rancher2_node_pool" "cp26" {
  cluster_id =  rancher2_cluster.rke_ec2.id
  name = "${var.prefix}-cp"
  hostname_prefix = "${var.prefix}-${random_string.random.result}-cp"
  node_template_id = rancher2_node_template.rke_template.id
  quantity = var.cp_count
  control_plane = true
  etcd = true
  worker = false

  depends_on = [
  rancher2_node_template.rke_template
  ]
}

resource "rancher2_node_pool" "wk26" {
  cluster_id = rancher2_cluster.rke_ec2.id
  name = "${var.prefix}-wk"
  hostname_prefix = "${var.prefix}-${random_string.random.result}-wk"
  node_template_id = rancher2_node_template.rke_template.id
  quantity = var.wk_count
  control_plane = false
  etcd = false
  worker = true

  depends_on = [
  rancher2_node_template.rke_template
  ]
}