#!/bin/bash


DATE=$(date +%m%d%H%M)
SAVEFILE=save_svc_state_$DATE.yml
RECREATE=recreate_without_wrong_selector_$DATE.yml

kubectl get svc -A -o wide | \
grep 'workloadID_' | \
awk '{print $1,$2}' | \
while read NS NAME; \
do \
kubectl -n $NS get svc $NAME -o yaml >> $SAVEFILE ; \
echo "---" >> $SAVEFILE; \
done

kubectl delete -f $SAVEFILE

sed '/workloadID_/d' $SAVEFILE | \
sed '/^  creationTimestamp:/d' | \
sed '/^  resourceVersion:/d' | \
sed '/^  uid:/d' | \
sed '/^  clusterIP:/d' | \
sed '/^  clusterIPs:/d' | \
sed '/^  - 10.43./d' | \
sed '/^status:/d' | \
sed '/^  loadBalancer:/d' | \
sed '/last-applied-configuration:/d' | \
sed '/^      {"apiVersion":"v1/d' \
> $RECREATE
kubectl apply -f $RECREATE