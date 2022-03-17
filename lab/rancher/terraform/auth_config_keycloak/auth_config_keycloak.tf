resource "rancher2_auth_config_keycloak" "keycloak" {
  display_name_field = "lab-display"
  groups_field = "lab-group"
  idp_metadata_content = "lab-idp"
  rancher_api_host = var.rancher_url
  sp_cert = "lab-cert"
  sp_key = "lab-key"
  uid_field = "lab-uid"
  user_name_field = "lab-user-field"
}