
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.xlarge"
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = "true"
  key_name                    = "leoaws"

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "labubuntu"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow ALL inbound traffic"

  ingress {
    description = "ALL from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K8s LAB"
  }
}