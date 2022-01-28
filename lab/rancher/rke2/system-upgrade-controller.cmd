kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.8.1/system-upgrade-controller.yaml

#

kubectl label nodes ip-172-31-2-36 rke2-upgrade=true

#

-n system-upgrade get plans
-n system-upgrade get jobs
-n system-upgrade get pods
