#!/bin/bash


DATE=$(date +%m%d%H%M)
SAVEFILE=save_svc_state_$DATE.yml
REMOVESELECTOR=remove_wrong_selector_$DATE.yml

kubectl get svc -A -o wide | \
grep 'workloadID_' | \
awk '{print $1,$2}' | \
while read NS NAME; \
do \
kubectl -n $NS get svc $NAME -o yaml >> $SAVEFILE ; \
echo "---" >> $SAVEFILE; \
done

sed '/workloadID_/d' $SAVEFILE | \
sed '/^  uid:/d' | \
sed '/last-applied-configuration:/d' | \
sed '/^      {"apiVersion":"v1/d' \
> $REMOVESELECTOR

kubectl apply -f $REMOVESELECTOR