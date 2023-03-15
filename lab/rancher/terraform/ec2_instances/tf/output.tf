output "instance_public_ip" {
    value = aws_instance.instance.*.public_ip
}

output "instance_public_dns" {
    value = aws_instance.instance.*.public_dns
}

output "instance_private_ip" {
    value = aws_instance.instance.*.private_ip
}

output "private_key_ssh" {
  value       = tls_private_key.global_key.private_key_openssh
  description = "private_key_ssh"
  sensitive   = true
}
