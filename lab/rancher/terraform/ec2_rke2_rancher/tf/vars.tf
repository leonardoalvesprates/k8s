variable aws_access_key {}
variable aws_secret_key {}

variable aws_region {
    default = "us-east-1"
}

variable aws_nsg {
    default = "all-open"
}

variable aws_instance_type {
    default = "t3a.xlarge"
}

variable prefix {
  type    = string
  default = "lprates"
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}