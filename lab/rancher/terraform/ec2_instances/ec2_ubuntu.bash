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

create() { 

get_aws_cred

docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform init

docker run --rm -v $(pwd)/tf:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform output -raw private_key_ssh > private_key_ssh.pem
chmod 600 private_key_ssh.pem


}

destroy() {

source .cred

docker run --rm -v $(pwd)/tf:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

}

help() {

printf "${green} Usage: script.bash <OPTION>${normal} \n"
printf "${green} ---  ${normal} \n"
printf "${green} OPTIONS: ${normal} \n"
printf " create ${green}- create upstream ${normal} \n"
printf " destroy ${green}- destroy upstream ${normal} \n"

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
*)
  help && exit 0
esac

