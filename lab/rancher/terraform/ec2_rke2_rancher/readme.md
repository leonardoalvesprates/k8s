### run terraform and ansible in docker

+++ export the variables with a space at the begging of the prompt, that won't get in your shell history
```
 export AWSKEY="<VALUE>"
 export AWSSECRET="<VALUE>"
```

+++ terraform init and plan
```
cd tf/
docker run --rm -v $(pwd):/lab leonardoalvesprates/tfansible terraform init

docker run --rm -v $(pwd):/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform plan
```

+++ terraform apply
```
docker run --rm -v $(pwd):/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform apply -auto-approve
```

+++ copy of instance public ip and private ssh key
```
docker run --rm -v $(pwd):/lab leonardoalvesprates/tfansible terraform output -raw private_key_ssh > private_key_ssh.pem 
docker run --rm -v $(pwd):/lab leonardoalvesprates/tfansible terraform output -raw instance_public_ip > instance_public_ip 
sudo chown $USER: instance_public_ip private_key_ssh.pem
cp instance_public_ip private_key_ssh.pem ../ && cd ..
export PUBLIC_IP=$(cat instance_public_ip)
```

+++ listRKE2 versions
```
curl -s https://raw.githubusercontent.com/rancher/rke/release/v1.3/data/data.json| grep v1.2 | grep rke2 |sed 's/"//g'|awk '{print $2}'|sort
```

+++ set rke2 version and install
```
export RKE2_VERSION=""

docker run --rm -v $(pwd):/lab \
-e PUBLIC_IP=$PUBLIC_IP \
-e RKE2_VERSION=$RKE2_VERSION \
-e ANSIBLE_HOST_KEY_CHECKING=False \
leonardoalvesprates/tfansible ansible-playbook -i $PUBLIC_IP, --private-key ./private_key_ssh.pem ansible/rke2.yaml
```

+++ set rancher repo, version and URL - install
```
export RANCHER_REPO=""      ### (stable/latest)
export RANCHER_VERSION=""
export RANCHER_URL=""

docker run --rm -v $(pwd):/lab \
-e PUBLIC_IP=$PUBLIC_IP \
-e RANCHER_REPO=$RANCHER_REPO \
-e RANCHER_VERSION=$RANCHER_VERSION \
-e RANCHER_URL=$RANCHER_URL \
-e ANSIBLE_HOST_KEY_CHECKING=False \
leonardoalvesprates/tfansible ansible-playbook -i $PUBLIC_IP, --private-key ./private_key_ssh.pem ansible/rancher.yaml
```

### destroy
```
cd tf/
docker run --rm -v $(pwd):/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve
```

