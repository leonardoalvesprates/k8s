variable rancher2_token_key {}
variable aws_access_key {}
variable aws_secret_key {}
variable rancher_url {
    default = "https://lprates-lab.support.rancher.space"
}
variable aws_eks_name {
    default = "lprates-eks-lab"
}
variable aws_region {
    default = "us-east-1"
}
variable aws_eks_service_role {
    default = "eksctl-lramage-eks-010-nodegroup-NodeInstanceRole-1R9ZB5IXAMLZT"
}