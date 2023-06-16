output "kube_config" {
  value = rancher2_cluster.rke_ec2.kube_config
  description = "kube_config data"
  sensitive = true
}