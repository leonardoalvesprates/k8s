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
  default = ""
}

variable "instance_count" {
  type    = number
  description = "Number of EC2 instances to create"
  default = 3
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

variable "should_create_ssh_key_pair" {
  type = bool
  description = "Specify if a new temporary SSH key pair needs to be created for the instances"
  default = false
}

variable "instance_ssh_key_name" {
  type = string
  description = "Specify the SSH key name to use (that's already present in AWS)"
  default = ""
}