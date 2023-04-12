resource "tls_private_key" "global_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "key_pair" {
  key_name_prefix = "${var.prefix}-"
  public_key      = tls_private_key.global_key.public_key_openssh
}

resource "aws_instance" "instance" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type

  key_name        = aws_key_pair.key_pair.key_name
  security_groups = ["${var.aws_nsg}"]

  root_block_device {
    volume_size = "50"
  }

  tags = {
    Name = "${var.prefix}-${random_string.random.result}-${count.index + 1}"
    Owner = var.prefix
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    # values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    # values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



