output "instance_public_ip" {
    value = aws_instance.instance.public_ip
}

output "instance_public_dns" {
    value = aws_instance.instance.public_dns
}

output "instance_private_ip" {
    value = aws_instance.instance.private_ip
}


