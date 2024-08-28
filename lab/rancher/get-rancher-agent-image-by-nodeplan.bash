#!/bin/bash

blue=$(tput setaf 6)
yellow=$(tput setaf 220)
normal=$(tput sgr0)

printf "${yellow}==== This works to gather RKE node info ONLY ==== \n"

for CLUSTER in $(kubectl get clusters.management.cattle.io --no-headers -o custom-columns=":metadata.name")
do
  if [[ "$CLUSTER" == "local" ]]
  then
    printf "${yellow}Not gathering local nodes info \n"
    printf "${normal}"
    
  else
    printf "${yellow} ${CLUSTER}\n"
    for NODE in $(kubectl -n $CLUSTER get nodes.management.cattle.io --no-headers -o custom-columns=":metadata.name")
    do
      NODEIMAGE=$(kubectl -n $CLUSTER get nodes.management.cattle.io $NODE -o jsonpath='{.status.nodePlan.plan.processes.share-mnt.image}{"\n"}')
      printf "${blue} ${NODE} ${NODEIMAGE}\n"
      printf "${normal}"
    done
    printf "${normal} \n"
  fi
done

printf "${blue} \n"
kubectl get clusters.management.cattle.io -o custom-columns="ID:.metadata.name,NAME:.spec.displayName,K8S_VERSION:.status.version.gitVersion,CREATED:.metadata.creationTimestamp,DELETED:.metadata.deletionTimestamp,LAST_READY:.status.conditions[?(@.type == 'Ready')].lastUpdateTime,READY:.status.conditions[?(@.type == 'Ready')].status" --sort-by=.metadata.creationTimestamp
printf "${normal}"