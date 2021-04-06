
resource "aws_instance" "vm_k8slab" {
  ami                         = "ami-0b416942dd362c53f" #fedora33hvm
  # subnet_id                   = 
  instance_type               = "t3.medium"
  key_name                    = "leoaws"
  associate_public_ip_address = "true"
  security_groups             = ["${aws_security_group.allow_all.name}"]

  # network_interface {
  #   network_interface_id  = aws_network_interface.if_k8slab.id
  #   device_index          = 0
  # }

  # credit_specification {
  #   cpu_credits = "unlimited"
  # }

  provisioner "remote-exec" {
    inline = ["echo 'wait until SSH is ready'"]

    connection {
      type = "ssh"
      user = "fedora"
      private_key = var.AWS_KEY_SSH
      host = aws_instance.vm_k8slab.public_ip
    }
  }

  # provisioner "local-exec" {
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${aws_instance.vm_k8slab.public_ip}, --private-key ./file.pem ../ansible/k8s.yaml"
  # }

  tags = {
    Name = "K8s LAB"
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