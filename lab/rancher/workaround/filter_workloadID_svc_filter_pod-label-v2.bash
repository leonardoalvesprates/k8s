#!/bin/bash

green=$(tput setaf 2)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
normal=$(tput sgr0)

for _namespace in `kubectl get ns --no-headers -o custom-columns=":.metadata.name"`
do
  printf "${normal} \n"
  printf "${green}Working with $_namespace namespace${normal}\\n"
  FILTER_WORKLOADID=$(kubectl -n $_namespace get svc -o wide|awk '$7 ~ /workloadID/ {print $0}')

  if [ ! -z "$FILTER_WORKLOADID" ]
  then
    _svcs_workloadid=$(kubectl -n $_namespace get svc -o wide|awk '$7 ~ /workloadID/ {print $1}')

    for _service in $_svcs_workloadid
    do
       printf "${yellow}Found workloadID in $_service service${normal}\\n"
       kubectl -n $_namespace get svc $_service -o wide --no-headers |awk '$7 ~ /workloadID/ {print $7}'

       _selectors=$(kubectl -n $_namespace get svc $_service -o wide --no-headers |awk '$7 ~ /workloadID/ {print $7}'| sed 's/\,/ /g')

       for _selector in $_selectors
       do

         if [[ "$_selector" == *"workloadID"* ]]
         then
           printf "${yellow}PODs labeled with ${normal}\\n"
           kubectl -n $_namespace get po --no-headers --show-labels | awk "/$_selector/"'{print $1,$6}'
         
           _podlabeled=$(kubectl -n $_namespace get po --no-headers --show-labels | awk "/$_selector/"'{print $6}'| sed 's/\,/ /g')
           for _podlabel in $_podlabeled
           do
             if [[ "$_podlabel" != *"workloadID"* ]] && [[ "$_podlabel" != *"pod-template-hash"* ]]
             then
             _newselectors=$(echo $(echo $_podlabel)","$(echo $_newselectors)|sed 's/,$//g')

             fi
           done
           printf "${yellow}Service _service new selector(s)${normal}\\n"
           printf "$_newselectors"

           # kubectl -n $_namespace patch svc $_service -p '{"spec":{"selector":{"app":"test1"}}}' --type merge
           # kubectl patch svc test1 -p '{"spec":{"selector":{"app":"test1"}}}' --type merge
           # kubectl annotate svc test1 field.cattle.io/targetWorkloadIds-
           # kubectl annotate svc test1 kubectl.kubernetes.io/last-applied-configuration-

         fi

       done

    done
  fi
done
