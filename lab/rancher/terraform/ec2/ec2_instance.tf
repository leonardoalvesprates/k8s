resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type

  key_name        = var.key_name
  security_groups = ["${var.aws_nsg}"]

  root_block_device {
    volume_size = "50"
  }

  tags = {
    Name = "quicklab-lp"
    Owner = "lprates"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
