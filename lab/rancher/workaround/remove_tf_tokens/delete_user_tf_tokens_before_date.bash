#!/bin/bash
TOKENS_BY_TF_USER=$( kubectl get tokens.management.cattle.io -l authn.management.cattle.io/kind=kubeconfig -o json | jq '.items | .[] | select (.userId == "user-m9stk") | .metadata.name ' | sed 's/"//g' )

for USERTOKEN in $(echo $TOKENS_BY_TF_USER)
do 
  kubectl get tokens.management.cattle.io $USERTOKEN -o json | jq 'select (.metadata.creationTimestamp<"2023-02-10") | .metadata.name ' | sed 's/"//g' | xargs kubectl delete tokens.management.cattle.io
done

# error: resource(s) were provided, but no name was specified
# This is expected if the token doesn't match the defined creationTimestamp