
resource "aws_instance" "vm_k8slab" {
  ami                        = "ami-05fc56020e2f7027a"
  instance_type              = "t3.medium"
  key_name                   = "leoaws"
  associate_public_ip_address = "true"

  network_interface {
    network_interface_id = aws_network_interface.if_k8slab.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "K8s LAB"
  }

}