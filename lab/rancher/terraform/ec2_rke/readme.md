### run terraform in docker

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

+++ copy of private ssh key
```
docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform output -raw private_key_ssh > private_key_ssh.pem
chmod 600 private_key_ssh.pem

```

+++ get outputs - instances public ip, provate ip and public dns
```
docker run --rm -v $(pwd)/tf:/lab leonardoalvesprates/tfansible terraform output 

```

### destroy
```
docker run --rm -v $(pwd)/tf:/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

```

