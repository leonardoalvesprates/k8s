output "ubuntu_ip" {
  value = aws_instance.ubuntu.*.public_ip
}