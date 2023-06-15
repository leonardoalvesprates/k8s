#!/bin/bash

green=$(tput setaf 2)
normal=$(tput sgr0)

get_aws_cred() {

printf "AWSKEY: "
read AWSKEY
export AWSKEY

printf "AWSSECRET: "
read AWSSECRET
export AWSSECRET

}

create() { 

get_aws_cred

printf "RKE2 Version <=1.24.x: "
read RKE2_VERSION
export RKE2_VERSION

printf "Rancher Version: "
read RANCHER_VERSION
export RANCHER_VERSION

printf "Rancher admin password: "
read ADMIN_PASS
export ADMIN_PASS


printf "${green}Creating ec2 instance...${normal} \n"
printf "${green}Terraform init...${normal} \n"
docker run --rm -v $(pwd)/tf_ec2_instance:/lab leonardoalvesprates/tfansible terraform init

printf "${green}Terraform apply...${normal} \n"
docker run --rm -v $(pwd)/tf_ec2_instance:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

printf "${green}Terraform outputs...${normal} \n"
docker run --rm -v $(pwd)/tf_ec2_instance:/lab leonardoalvesprates/tfansible terraform output -raw private_key_ssh > private_key_ssh.pem 
docker run --rm -v $(pwd)/tf_ec2_instance:/lab leonardoalvesprates/tfansible terraform output -raw instance_public_ip > instance_public_ip 
chmod 600 instance_public_ip private_key_ssh.pem

printf "${green}Sleeping 120 secs...${normal} \n"
sleep 120

printf "${green}Installing RKE2 $(echo $RKE2_VERSION)...${normal} \n"
export PUBLIC_IP=$(cat instance_public_ip)
docker run --rm -v $(pwd):/lab \
-e PUBLIC_IP=$PUBLIC_IP \
-e RKE2_VERSION=$RKE2_VERSION \
-e ANSIBLE_HOST_KEY_CHECKING=False \
leonardoalvesprates/tfansible ansible-playbook -i $PUBLIC_IP, --private-key ./private_key_ssh.pem ansible/rke2.yaml


printf "${green}Setting stable repo and Rancher URL $(cat instance_public_ip).nip.io ${normal} \n"
export RANCHER_REPO="stable"
export RANCHER_URL="$(cat instance_public_ip).nip.io"

printf "${green}Installing Rancher $(echo $RANCHER_VERSION) ...${normal} \n"
docker run --rm -v $(pwd):/lab \
-e PUBLIC_IP=$PUBLIC_IP \
-e RANCHER_REPO=$RANCHER_REPO \
-e RANCHER_VERSION=$RANCHER_VERSION \
-e RANCHER_URL=$RANCHER_URL \
-e ADMIN_PASS=$ADMIN_PASS \
-e ANSIBLE_HOST_KEY_CHECKING=False \
leonardoalvesprates/tfansible ansible-playbook -i $PUBLIC_IP, --private-key ./private_key_ssh.pem ansible/rancher.yaml

}

destroy() {

get_aws_cred

docker run --rm -v $(pwd)/tf_ec2_instance:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve


}

help() {

printf "${green} Usage: ec2_rke2_rancher.bash <OPTION>${normal} \n"
printf "${green} OPTION:${normal} \n"
printf "${green} help ${normal} \n"
printf "${green} create ${normal} \n"
printf "${green} destroy ${normal} \n"
printf "${green} cred_rke_node_template ${normal} \n"


}

cred_rke_node_template() {

printf "${green} Setting Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"

export RANCHER_URL_HTTPS="https://$(cat instance_public_ip).nip.io"

printf "Rancher beared token: "
read RANCHER_TOKEN
export RANCHER_TOKEN

printf "${green} Terraform init and apply... ${normal} \n"
docker run --rm -v $(pwd)/tf_credential_node_template:/lab leonardoalvesprates/tfansible terraform init
docker run --rm -v $(pwd)/tf_credential_node_template:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url_https="${RANCHER_URL_HTTPS}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN}" \
leonardoalvesprates/tfansible terraform  apply -auto-approve

}


case $1 in
create)
  create
  ;;
destroy)
  destroy
  ;;
help)
  help
  ;;
cred_rke_node_template)
  cred_rke_node_template
  ;;
*)
  help && exit 0
esac
