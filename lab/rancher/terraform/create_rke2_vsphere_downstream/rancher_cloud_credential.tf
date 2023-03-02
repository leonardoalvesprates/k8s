resource "rancher2_cloud_credential" "vsphere" {
  name = "${var.prefix}-${random_string.random.result}"
  vsphere_credential_config {
    pasword      = "" # or var
    username     = "" # or var
    vcenter      = "" # or var
    vcenter_port = "" # or var
  }
}