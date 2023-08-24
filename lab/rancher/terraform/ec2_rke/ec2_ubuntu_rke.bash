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

docker run --rm -v $(pwd)/ec2_instance:/lab leonardoalvesprates/tfansible terraform init

docker run --rm -v $(pwd)/ec2_instance:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

docker run --rm -v $(pwd)/ec2_instance:/lab leonardoalvesprates/tfansible terraform output -raw private_key_ssh > private_key_ssh.pem
chmod 600 private_key_ssh.pem
cp private_key_ssh.pem rke/

docker run --rm -v $(pwd)/ec2_instance:/lab leonardoalvesprates/tfansible terraform output instance_public_ip|egrep -v '\[|\]'|sed 's/"//g'|sed 's/,//g'|sed 's/^  //g' > instances_ips.out
head -1 instances_ips.out > rke/instance_1_ip
head -2 instances_ips.out | tail -1 > rke/instance_2_ip
tail -1 instances_ips.out > rke/instance_3_ip

sleep 30

for INSTANCE in 1 2 3 
do
ssh -o StrictHostKeyChecking=no -i private_key_ssh.pem ubuntu@$(cat instance_"$INSTANCE"_ip) "sudo curl https://releases.rancher.com/install-docker/20.10.sh | sh"
sleep 10
ssh -o StrictHostKeyChecking=no -i private_key_ssh.pem ubuntu@$(cat instance_"$INSTANCE"_ip) "sudo usermod -G docker ubuntu"
done

docker run --rm -v $(pwd)/rke:/lab leonardoalvesprates/tfansible terraform init
docker run --rm -v $(pwd)/rke:/lab leonardoalvesprates/tfansible terraform apply -auto-approve

}

destroy() {

source .cred

docker run --rm -v $(pwd)/ec2_instance:/lab \
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

