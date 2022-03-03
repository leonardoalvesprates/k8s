variable rancher2_token_key {}
variable aws_access_key {}
variable aws_secret_key {}
variable rancher_url {
    default = "https://rancher26.prateslabs.com.br"
}
variable aws_region {
    default = "us-east-1"
}
variable rke_node_template_name{
    default = "rke-ec2-template"
}
variable rke_cluster_name {
    default = "rke-ec2-downstream"
}
variable aws_subnet {
    default = "subnet-ab21ac85"
}
variable aws_vpc {
    default = "vpc-e23ae898"
}
variable aws_nsg {
    default = "sg-052c40e46fd744af9"
}
variable aws_ami {
    default = "ami-04505e74c0741db8d"
}
variable aws_instance_type {
    default = "t3a.large"
}