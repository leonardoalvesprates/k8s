* install monitoring + longhorn 1.2.4 through UI
* set LH backup endpoint + LH backup endpoint creds
* set "Storage Over Provisioning Percentage" to 20000

* create 300 LH volumes
```
for VOL in $(seq 1 300); do export VOL; envsubst < volumes-template.yml |kubectl apply -f -; done
```

* list the 300 volumes, split and attach to 5 different nodes
```
kubectl -n longhorn-system get volumes --no-headers -o custom-columns=":metadata.name" > volumes.out
split volumes.out -l 60
for I in $(cat xaa); do kubectl -n longhorn-system patch volume $I -p '{"spec":{"nodeID":"wk1"}}' --type=merge; done
for I in $(cat xab); do kubectl -n longhorn-system patch volume $I -p '{"spec":{"nodeID":"wk2"}}' --type=merge; done
for I in $(cat xac); do kubectl -n longhorn-system patch volume $I -p '{"spec":{"nodeID":"wk3"}}' --type=merge; done
for I in $(cat xad); do kubectl -n longhorn-system patch volume $I -p '{"spec":{"nodeID":"wk4"}}' --type=merge; done
for I in $(cat xae); do kubectl -n longhorn-system patch volume $I -p '{"spec":{"nodeID":"wk5"}}' --type=merge; done
```

* create recurringJob - for each 5 minutes, retain 70, concurrency 50, default group
```
kubectl apply -f recurringJob.yml
```



######### FUTURE Lab ###########
### create some workload 
### create 300 pv, pvc and deployment attaching that
for NR in $(seq 1 300); do export NR; envsubst < pv-pvc-deploy.yml |kubectl apply -f -; done

### delete everything
### delete all default namespaced deployment
kubectl -n default delete deploy $(kubectl -n default get deploy --no-headers -o custom-columns=":metadata.name")

### delete all default namespaced pvc
kubectl delete pvc $(kubectl get pvc --no-headers -o custom-columns=":metadata.name")

### delete all pv
kubectl delete pv $(kubectl get pv --no-headers -o custom-columns=":metadata.name")

### delete all LH volumes
kubectl -n longhorn-system delete volume $(kubectl -n longhorn-system get volumes --no-headers -o custom-columns=":metadata.name")


