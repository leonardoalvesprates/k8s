output "k8slab_ip" {
    value = aws_instance.vm_k8slab.public_ip
}