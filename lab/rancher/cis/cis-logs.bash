#!/bin/bash

while true
  do 
  for POD in $(kubectl -n cis-operator-system get pod -l component=sonobuoy --no-headers -o custom-columns=":metadata.name")
  do 
    kubectl -n cis-operator-system describe pod $POD >> $POD-desc.out
    echo “=== === === === ===” >> $POD-desc.out
    kubectl -n cis-operator-system logs $POD -c sonobuoy-worker >> $POD-log.out
    echo “=== === === === ===” >> $POD-log.out
  done
  for POD in $(kubectl -n cis-operator-system get pod -l cis.cattle.io/controller=cis-operator --no-headers -o custom-columns=":metadata.name")
  do 
    kubectl -n cis-operator-system describe pod $POD >> $POD-desc.out
    echo “=== === === === ===” >> $POD-desc.out
    kubectl -n cis-operator-system logs $POD >> $POD-log.out
    echo “=== === === === ===” >> $POD-log.out
  done
done