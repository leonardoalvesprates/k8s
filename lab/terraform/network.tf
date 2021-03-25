resource "aws_vpc" "vpc_lab" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_lab" {
  vpc_id            = aws_vpc.vpc_lab.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1"

  tags = {
    Name = "K8s LAB"
  }
}

resource "aws_network_interface" "if_k8slab" {
  subnet_id   = aws_subnet.subnet_lab.id
#   private_ips = ["172.16.10.100"]

  tags = {
    Name = "K8s LAB"
  }
}