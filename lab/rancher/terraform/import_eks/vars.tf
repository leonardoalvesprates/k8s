variable rancher2_token_key {}
variable aws_access_key {}
variable aws_secret_key {}
variable rancher_url {
    default = "https://rancher26.prateslabs.com.br"
}
variable aws_eks_name {
    default = "lprates-apr18-2"
}
variable aws_region {
    default = "us-east-1"
}
variable aws_eks_service_role {
    default = "eks-worker-node"
}