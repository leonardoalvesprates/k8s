#!/bin/bash
echo
echo
echo 'overlaytest PODS'
echo
kubectl -n default get pods -l name=overlaytest -o wide
echo
echo '################'
echo
echo 'creating single web pod'
kubectl -n default run web-first --image=leonardoalvesprates/web-first:v0.1 --port=8080
echo
echo 'waiting 60 seconds'
sleep 60
echo 'creating clusterIP svc for web-first'
kubectl -n default expose pod web-first --port=80 --target-port=8080
echo
echo 'waiting 10 seconds'
sleep 10
echo
echo 'listing pods and svc default namespace'
echo
kubectl -n default get pod,svc -o wide
echo
echo
echo 'running some tests'
echo
for POD in $(kubectl -n default get pods -l name=overlaytest --no-headers -o custom-columns=":metadata.name")
do
  echo $POD
  kubectl -n default exec -it $POD -- nslookup web-first 
  kubectl -n default exec -it $POD -- curl http://web-first
  echo
  echo
done
echo 'deleting web pod and svc'
kubectl -n default delete pod web-first
kubectl -n default delete svc web-first
echo 'waiting 30 seconds'
sleep 30
echo
kubectl -n default get pod,svc -o wide