variable rancher2_token_key {}
variable aws_access_key {}
variable aws_secret_key {}
variable rancher_url {}

variable aws_region {
    default = "us-east-1"
}

variable aws_zone {
    default = "a"
}

variable aws_instance_type {
    default = "t3a.large"
}

variable aws_nsg {
    default = "all-open"
}

variable aws_vpc {
    default = "vpc-e23ae898"
}

variable aws_subnet {
    default = "subnet-ab21ac85"
}

variable iam_profile {
    default = "rk-all-role"
}

variable kubernetes_version {
    default = "v1.23.8+rke2r1"
}

variable prefix {
    default = "lprates"
}

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

