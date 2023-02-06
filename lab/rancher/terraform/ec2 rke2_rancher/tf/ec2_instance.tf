resource "tls_private_key" "global_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "key_pair" {
  key_name_prefix = "${var.prefix}-key_pair"
  public_key      = tls_private_key.global_key.public_key_openssh
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type

  key_name        = aws_key_pair.key_pair.key_name
  security_groups = ["${var.aws_nsg}"]

  root_block_device {
    volume_size = "50"
  }

  tags = {
    Name = "${var.prefix}-quicklab"
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



