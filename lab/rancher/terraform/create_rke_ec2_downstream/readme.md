### run terraform and ansible in docker

+++ (a lot of pinned set, take look at vars.tf)

+++ export the variables with a space at the begging of the prompt, that won't get that in your shell history
```
 export AWSKEY="<VALUE>"
 export AWSSECRET="<VALUE>"
 export RANCHER_URL="<VALUE>"  ### e.g. https://rancher.lab
 export RANCHER_TOKEN_KEY="<VALUE>"
```

+++ terraform init and plan
```
docker run --rm -v $(pwd):/lab leonardoalvesprates/tfansible terraform init

docker run --rm -v $(pwd):/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN_KEY}" \
leonardoalvesprates/tfansible terraform plan

```

+++ terraform apply
```
docker run --rm -v $(pwd):/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN_KEY}" \
leonardoalvesprates/tfansible terraform apply -auto-approve

```

+++ copy of kubeconfig
```
docker run --rm -v $(pwd):/lab leonardoalvesprates/tfansible terraform output -raw kube_config > kube_config.yaml 

```

### destroy downstream cluster
```
docker run --rm -v $(pwd):/lab \
-e TF_VAR_aws_access_key="${AWSKEY}" \
-e TF_VAR_aws_secret_key="${AWSSECRET}" \
-e TF_VAR_rancher_url="${RANCHER_URL}" \
-e TF_VAR_rancher2_token_key="${RANCHER_TOKEN_KEY}" \
leonardoalvesprates/tfansible terraform destroy -auto-approve

```