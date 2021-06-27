output "ubuntu_ip" {
  value = aws_instance.ubuntu.[0].public_ip
}