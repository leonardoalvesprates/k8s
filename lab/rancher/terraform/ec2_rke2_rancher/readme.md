### run terraform and ansible in docker

+++ (pinned prefix, NSG and AWS Region tf/vars.tf - must put some string at prefix variable)

+++ export the variables with a space at the begging of the prompt, that won't get that in your shell history

```
 export AWSKEY="<VALUE>"
 export AWSSECRET="<VALUE>"
```

+++ terraform init and plan
```
docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform init

docker run --rm -v $(pwd)/tf:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform plan

```

+++ terraform apply
```
docker run --rm -v $(pwd)/tf:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

```

+++ copy of instance public ip and private ssh key
```
docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform output -raw private_key_ssh > private_key_ssh.pem 
docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform output -raw instance_public_ip > instance_public_ip 
chmod 600 instance_public_ip private_key_ssh.pem

```

+++ list RKE2 versions
```
curl -sL https://raw.githubusercontent.com/rancher/rke/release/v1.3/data/data.json |jq -r '.rke2.releases[].version'

```

+++ choose and set rke2 version 
```
export RKE2_VERSION=""
```

+++ install RKE2
```
export PUBLIC_IP=$(cat instance_public_ip)
docker run --rm -v $(pwd):/lab \
-e PUBLIC_IP=$PUBLIC_IP \
-e RKE2_VERSION=$RKE2_VERSION \
-e ANSIBLE_HOST_KEY_CHECKING=False \
leonardoalvesprates/tfansible ansible-playbook -i $PUBLIC_IP, --private-key ./private_key_ssh.pem ansible/rke2.yaml

```

+++ choose and set rancher repo, version and URL
```
export RANCHER_REPO=""      ### stable or latest
export RANCHER_VERSION=""   ### e.g. 2.6.9, 2.7.1, 2.6.3
export RANCHER_URL=""       ### that can be ec2 public IPv4 DNS (the terraform output of instance_public_dns from the terraform apply above)
                            ### or <PUBLIC_IP>.nip.io
```

+++ install rancher
```
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
docker run --rm -v $(pwd)/tf:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

```

