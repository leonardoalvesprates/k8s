#!/bin/bash

green=$(tput setaf 2)
normal=$(tput sgr0)

get_aws_cred() {

stty -echo

printf "AWSKEY: "
read AWSKEY
export AWSKEY
printf "\n"

printf "AWSSECRET: "
read AWSSECRET
export AWSSECRET
printf "\n"

stty echo

echo AWSKEY=$(echo $AWSKEY) > .cred
echo AWSSECRET=$(echo $AWSSECRET) >> .cred

}

create_upstream() { 

get_aws_cred

printf "RKE2 versions \n"
printf "${green}curl -sL https://raw.githubusercontent.com/rancher/rke/release/v1.3/data/data.json |jq -r '.rke2.releases[].version'${normal} \n"
printf "${green}curl -sL https://raw.githubusercontent.com/rancher/rke/release/v1.4/data/data.json |jq -r '.rke2.releases[].version'${normal} \n"

printf "RKE2 Version <=1.24.x: "
read RKE2_VERSION
export RKE2_VERSION

printf "Rancher Version (e.g 2.7.1): "
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

printf "${green} Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"

}

destroy_upstream() {

source .cred

docker run --rm -v $(pwd)/tf_ec2_instance:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

}

help() {

printf "${green} Usage: ec2_rke2_rancher.bash <OPTION>${normal} \n"
printf "${green} ---  ${normal} \n"
printf "${green} OPTIONS: ${normal} \n"
printf " create_upstream ${green}- create upstream ${normal} \n"
printf " destroy_upstream ${green}- destroy upstream ${normal} \n"
printf " beared_token ${green}- save beared token - need (create) ${normal} \n"
printf " cred_rke_node_template ${green}- needs (create, beared token) ${normal} \n"
printf " rke2_downstream ${green}- need (create, beared token) ${normal} \n"
printf " rke2_downstream_destroy ${green}- need (create, beared token) ${normal} \n"
printf " rke_downstream ${green}- need (create, beared token) ${normal} \n"
printf " rke_downstream_destroy ${green}- need (create, beared token) ${normal} \n"
printf " help ${green}- this message ${normal} \n"
printf " info ${green}- info TF files ${normal} \n"

}

info(){

printf "${green} ---  ${normal} \n"
printf "${green} * pre-reqs *  ${normal} \n"
printf "${green} set variables prefix ${normal} \n"
printf "   - vi tf_ec2_instance/vars.tf ${normal} \n"
printf "   - vi tf_credential_node_template/vars.tf ${normal} \n"
printf "   - vi tf_rke2_downstream/vars.tf ${normal} \n"
printf "   - vi tf_rke_downstream/vars.tf ${normal} \n"
printf "${green} -----------------------------------------------------------------------------------  ${normal} \n"
printf "${green} upstream instance ${normal} \n"
printf " aws_ami ${green}- tf_ec2_instance/ec2_instance.tf ${normal} \n"
printf " aws_region, aws_nsg, aws_instance_type ${green}- tf_ec2_instance/vars.tf ${normal} \n"
printf "${green} ---  ${normal} \n"
printf "${green} aws cloud credentials and RKE node template ${normal} \n"
printf " aws_region, aws_subnet, aws_vpc, aws_nsg, aws_instance_type, iam_profile ${green}- tf_credential_node_template/vars.tf ${normal} \n"
printf "${green} ---  ${normal} \n"
printf "${green} RKE2 downstream ${normal} \n"
printf " aws_ami ${green}- tf_rke2_downstream/aws_ami.tf ${normal} \n"
printf " machine_global_config, WORKER quantity, CONTROLPLANE quantity ${green}- tf_rke2_downstream/main.tf ${normal} \n"
printf " aws_region, aws_zone, aws_instance_type, aws_nsg, aws_vpc, aws_subnet, iam_profile, kubernetes_version ${green}- tf_rke2_downstream/vars.tf ${normal} \n"

}

beared_token() {

printf "Rancher beared token: "
read RANCHER_TOKEN
export RANCHER_TOKEN

echo RANCHER_TOKEN=$(echo $RANCHER_TOKEN) > .beared_token

}

cred_rke_node_template() {

source .cred
source .beared_token

printf "${green} Setting Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"

export RANCHER_URL_HTTPS="https://$(cat instance_public_ip).nip.io"

printf "${green} Terraform init and apply... ${normal} \n"
docker run --rm -v $(pwd)/tf_credential_node_template:/lab leonardoalvesprates/tfansible terraform init
docker run --rm -v $(pwd)/tf_credential_node_template:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url_https="${RANCHER_URL_HTTPS}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN}" \
leonardoalvesprates/tfansible terraform  apply -auto-approve

}

rke2_downstream() {

source .cred
source .beared_token

printf "${green} Setting Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"
export RANCHER_URL="https://$(cat instance_public_ip).nip.io"

docker run --rm -v $(pwd)/tf_rke2_downstream:/lab leonardoalvesprates/tfansible terraform init
docker run --rm -v $(pwd)/tf_rke2_downstream:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

}

rke2_downstream_destroy() {

source .cred
source .beared_token

printf "${green} Setting Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"
export RANCHER_URL="https://$(cat instance_public_ip).nip.io"

docker run --rm -v $(pwd)/tf_rke2_downstream:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

}

rke_downstream() {

source .cred
source .beared_token

printf "${green} Setting Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"
export RANCHER_URL="https://$(cat instance_public_ip).nip.io"

docker run --rm -v $(pwd)/tf_rke_downstream:/lab leonardoalvesprates/tfansible terraform init
docker run --rm -v $(pwd)/tf_rke_downstream:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

}

rke_downstream_destroy() {

source .cred
source .beared_token

printf "${green} Setting Rancher URL to https://$(cat instance_public_ip).nip.io ${normal} \n"
export RANCHER_URL="https://$(cat instance_public_ip).nip.io"

docker run --rm -v $(pwd)/tf_rke_downstream:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

}

case $1 in
create_upstream)
  create_upstream
  ;;
destroy_upstream)
  destroy_upstream
  ;;
help)
  help
  ;;
cred_rke_node_template)
  cred_rke_node_template
  ;;
rke2_downstream)
  rke2_downstream
  ;;
rke2_downstream_destroy)
  rke2_downstream_destroy
  ;;
rke_downstream)
  rke_downstream
  ;;
rke_downstream_destroy)
  rke_downstream_destroy
  ;;
beared_token)
  beared_token
  ;;
info)
  info
  ;;
*)
  help && exit 0
esac

