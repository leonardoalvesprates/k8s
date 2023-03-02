variable rancher_url {
    default = "https://RANCHERURL"
}

variable rancher2_token_key {
    default = "token-....."  # rancher admin bearer token (User Avatar > API & Keys from the User Settings menu in the upper-right.)
}

variable prefix {
    default = ""
}

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

variable kubernetes_version {
    default = "v1.23.8+rke2r1"
}

