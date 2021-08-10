output "opensuse_ip" {
    value = aws_instance.opensuse.*.public_ip
}