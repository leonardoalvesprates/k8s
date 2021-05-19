## Install / bootstrapping

### Common images
```
k8s.gcr.io/kube-apiserver:v1.17.0
k8s.gcr.io/kube-controller-manager:v1.17.0
k8s.gcr.io/kube-scheduler:v1.17.0
k8s.gcr.io/kube-proxy:v1.17.0
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.5
```

### kubeadm

#### Flannel (docker)

`sysctl net.bridge.bridge-nf-call-iptables=1`

`kubeadm init --pod-network-cidr=10.244.0.0/16`

#### Pulling images

`kubeadm config images pull`

#### create token and print join command

`kubeadm token create --print-join-command`

## kubectl

### bash completion

`source <(kubectl completion bash)`

### verbose

`kubectl --v=10 get pods nginx`

## Deployment

### create simple deploy

`kubectl create deployment web --image=nginx`

### change image

`kubectl set image deployment tomcat tomcat=tomcat:9.0.19-jre8-alpine`

### rollout

`kubectl rollout history deployment <deployname>`

`kubectl rollout undo daemonset <deployname>`

`kubectl rollout undo deployment <deployname> --to-revision=X`

`kubectl rollout status daemonset <deployname>`

```
   strategy:
     rollingUpdate:
       maxSurge: 25%
       maxUnavailable: 25%
     type: RollingUpdate
     ...
     type: OnDelete
```

### expose

`kubectl expose deployment php --port=80 --type=NodePort`

`kubectl expose deployment tomcat --type=NodePort`

```
      containers:
        ports:
        - containerPort: 8080
          protocol: TCP
```

### scale

`kubectl scale deployment tomcat --replicas=20`

### replicas (deployment yaml file)

```
spec:
  replicas: 1
```

### nodeSeletor

```
      containers:
      nodeSelector:
        app: frontend
```

### nodeAffinity

```
     spec:
       affinity:
         nodeAffinity:
           requiredDuringSchedulingIgnoredDuringExecution:
             nodeSelectorTerms:
             - matchExpressions:
               - key: "app"
               operator: In
               values: ["backend"]
       containers:
```

### container command

```
      containers:
        command: ["/bin/bash", "-c", "--"]
        args: ["while true; do sleep 600; done"]
```

### livenessProbe

```
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

## DaemonSet

`kubectl create deployment nginx --image=nginx:1.16.0`
`kubectl get deployments. nginx -o yaml --export > dset.yaml`

Edit/Remove

`kind: DaemonSet`

Remove

 `annotations, creationTimestamp, generation, selfLink, progressDeadlineSeconds, strategy:, status: {}`


`kubectl create -f dset.yaml`

Options

```
spec:
  ....
  updateStrategy:
    type: RollingUpdate
  minReadySeconds: 30
```

## livenessProbe / readinessProbe

```
spec:
  containers:
  - image: nginx:1.16.0
    imagePullPolicy: IfNotPresent
    name: nginx
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
    readinessProbe:
      exec:
        command:
        - ls
        - /tmp/
      initialDelaySeconds: 5
      periodSeconds: 5
```

## Taint

### remove taint from master

`kubectl taint nodes <master-node> node-role.kubernetes.io/master-`

### set taint to master NoSchedule

`kubectl taint nodes <master-node> node-role.kubernetes.io/master=true:NoSchedule`

### set taint to node NoExecute

`kubectl taint node flannel-2 remove=true:NoExecute`

`kubectl taint node flannel-2 remove-`

## Tolerations

```
kubectl describe node <node> | grep Taints
Taints:             node-role.kubernetes.io/master=true:NoSchedule
```

### yaml file

```
      containers:
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
```

## Drain / Uncordon

`kubectl drain flannel-3 --ignore-daemonsets --delete-local-data`

`kubectl uncordon flannel-3`

## ConfigMaps

`kubectl create configmap php-index --from-file=index.php`

```
containers:
- image: php:apache
  name: php
  ports:
  - containerPort: 80
    protocol: TCP
  volumeMounts:
  - name: index-file
    mountPath: /var/www/html/
    subPath: index.php
volumes:
  - name: index-file
    configMap:
      name: php-index
      items:
      - key: index.php
        path: index.php
```

## Service

### yaml file

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: php
  name: php
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: php
  type: NodePort
```

### Secret

### from files

`kubectl create secret generic mysecret --from-file=.username.txt --from-file=.password.txt`

### from prompt

`kubectl create secret generic test-secret --from-literal=username='my-app' --from-literal=password='39528$vdg7Jb'`

### yaml file

```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4K
  password: MTIzNDU2Cg==
```

```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret2
type: Opaque
stringData:
  config.yaml: |-
    apiUrl: "https://my.api.com/api/v1"
    username: {{username}}
    password: {{password}}
```

### pod yaml

```
containers:
  volumeMounts:
  - name: secret-volume
    mountPath: /etc/secret-volume
volumes:
  - name: secret-volume
    secret:
    secretName: test-secret
```

## API

### Checking

`kubectl auth can-i create deployments`

`kubectl auth can-i create deployments --as bob`

`kubectl auth can-i create deployments -n kube-system`

### Inside container

```
# pwd
/var/run/secrets/kubernetes.io/serviceaccount

curl https://10.142.0.2:6443/api/v1 --header "Authorization: Bearer $(cat token)" -k
```

## Context

`kubectl config view`

`kubectl config get-clusters`

`kubectl config get-contexts`

## ServiceAccounts

```
kubectl describe serviceaccounts default | grep Tokens
Tokens:              default-token-8fbcw
```

```
kubectl get secrets | grep default
default-token-8fbcw   kubernetes.io/service-account-token   3      48d
```

```
kubectl describe pod fedora-bc487fb88-tjxj4 | grep -A1 Mounts
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-8fbcw (ro)
```

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
EOF
```

## StatefulSet

```
apiVersion: apps/v1
kind: StatefulSet
```

### Headless services

None for ClusterIP

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
```

### Management Policies

```
spec:
  podManagementPolicy: OrderedReady
```

```
spec:
  podManagementPolicy: Parallel
```

### POD name into label

```
$kubectl describe pod web-0
Name:               web-0
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               flannel-3/10.128.0.8
Start Time:         Tue, 14 May 2019 23:16:03 +0000
Labels:             app=nginx
                    controller-revision-hash=web-6596ffb49b
                    statefulset.kubernetes.io/pod-name=web-0
```

## ETCD

`$ kubectl -n kube-system exec -it etcd-flannel-1 sh`

`$ etcdctl-3.2.24 --endpoints=https://10.142.0.2:2379 --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=./server.key member list`

## ACCESS

### creating Namespace

`prates  flannel-1  /home/prates  kubectl create namespace accessk8s`

### creating user into linux

`useradd -c "access k8s" -m access`

### clear config view

```
access@flannel-1:~$ kubectl config view
apiVersion: v1
clusters: []
contexts: []
current-context: ""
kind: Config
preferences: {}
users: []
```

### creating key - openssl

`access@flannel-1:~$ openssl genrsa -out access.key 2048`

### requesting CSR user/namespace - openssl

`access@flannel-1:~$ openssl req -new -key access.key -out access.csr -subj "/CN=access/O=accessk8s"`

### creating certificate - CRT

```
prates  flannel-1  /home/prates$  sudo openssl x509 -req -in /home/access/access.csr \
> -CA /etc/kubernetes/pki/ca.crt \
> -CAkey /etc/kubernetes/pki/ca.key \
> -CAcreateserial \
> -out /home/access/access.crt -days 365
Signature ok
subject=/CN=access/O=accessk8s
Getting CA Private Key
```

### set-credentials

```
access@flannel-1:~$ kubectl config set-credentials access --client-certificate=/home/access/access.crt --client-key=/home/access/access.key
User "access" set.
```

```
access@flannel-1:~$ kubectl config view
apiVersion: v1
clusters: []
contexts: []
current-context: ""
kind: Config
preferences: {}
users:
- name: access
  user:
    client-certificate: /home/access/access.crt
    client-key: /home/access/access.key
```

### set-context

```
access@flannel-1:~$ kubectl config set-context Access-context --cluster=kubernetes --namespace=accessk8s --user=access
Context "Access-context" created.
```

```
access@flannel-1:~$ kubectl config view
apiVersion: v1
clusters: []
contexts:
- context:
    cluster: kubernetes
    namespace: accessk8s
    user: access
  name: Access-context
current-context: ""
kind: Config
preferences: {}
users:
- name: access
  user:
    client-certificate: /home/access/access.crt
    client-key: /home/access/access.key
```

### set-cluster server

```
access@flannel-1:~$ kubectl config set-cluster kubernetes --server=https://10.142.0.2:6443
Cluster "kubernetes" set.
```

### take CA.CERT

```
root@flannel-1:~# cat /etc/kubernetes/pki/ca.crt > /home/access/ca.crt
root@flannel-1:~# chown access:access /home/access/ca.crt
```

### set-cluster certificate

```
access@flannel-1:~$ kubectl config set-cluster kubernetes --certificate-authority=/home/access/ca.crt
Cluster "kubernetes" set.
```

```
access@flannel-1:~$ kubectl config get-contexts
CURRENT   NAME             CLUSTER      AUTHINFO   NAMESPACE
          Access-context   kubernetes   access     accessk8s
```

### --context

```
access@flannel-1:~$ kubectl --context=Access-context get pod
Error from server (Forbidden): pods is forbidden: User "access" cannot list resource "pods" in API group "" in the namespace "accessk8s"
```

### use-context

```
access@flannel-1:~$ kubectl config use-context Access-context

access@flannel-1:~$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/access/ca.crt
    server: https://10.142.0.2:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: accessk8s
    user: access
  name: Access-context
current-context: Access-context
kind: Config
preferences: {}
users:
- name: access
  user:
    client-certificate: /home/access/access.crt
    client-key: /home/access/access.key
```

## Roles, rolebinding

### creating role

`kubectl create -f role-access.yaml`

```
$ cat role-access.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: accessk8s
  name: user-access
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["list", "get", "watch", "create", "update", "patch", "delete", "logs"]
# You can use ["*"] for all verbs
```

### creating rolebinding

`kubectl create -f rolebind-user-access.yaml`

```
$ cat rolebind-user-access.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: user-access-role-binding
  namespace: accessk8s
subjects:
- kind: User
  name: access
  apiGroup: ""
roleRef:
  kind: Role
  name: user-access
  apiGroup: ""
```

### admin rolebinding as namespace admin

```
$ cat rolebind-user-access.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: user-access-role-binding
  namespace: accessk8s
subjects:
- kind: User
  name: access
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: ""

```

## Cluster start sequence

systemctl status kubelet.services

`/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`

Uses `/var/lib/kubelet/config.yaml`

staticPodPath is set to `/etc/kubernetes/manifests/`


## Troubleshooting

### apps

`kubectl logs ${POD_NAME} ${CONTAINER_NAME}`

`kubectl logs --previous ${POD_NAME} ${CONTAINER_NAME}`

### cluster

`kubectl get nodes`

### logs

#### masters

```
/var/log/kube-apiserver.log
/var/log/kube-scheduler.log
/var/log/kube-controller-manager.log
```

#### workers

```
/var/log/kubelet.log
/var/log/kube-proxy.log
```

## Security Contexts

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  securityContext:
    runAsNonRoot: True
  containers:
  - image: nginx
    name: nginx
```

## Ingress

#### service

```
$ kubectl get svc apache -o yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: apache
  name: apache
  namespace: default
```

#### Ingress

```
$ cat ingress-httpd.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-httpd
spec:
  rules:
  - host: www.my-httpd.com.br
    http:
      paths:
      - backend:
          serviceName: apache
          servicePort: 80
        path: /
```

## Auditing

```
touch /var/log/kube-audit
vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

```
- command:
  - kube-apiserver
....
- --audit-policy-file=/etc/kubernetes/manifests/audit-policy.yaml
- --audit-log-path=/var/log/kube-audit
- --audit-log-format=json
....
volumeMounts:
....
- mountPath: /etc/kubernetes/manifests/audit-policy.yaml
  name: audit-file-config
  readOnly: true
- mountPath: /var/log/kube-audit
  name: audit-log-file
  readOnly: false
....
volumes:
....
- hostPath:
    path: /etc/kubernetes/manifests/audit-policy.yaml
    type: "FileOrCreate"
  name: audit-file-config
- hostPath:
    path: /var/log/kube-audit
    type: "FileOrCreate"
  name: audit-log-file
```

### HPA

```
kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --limits=cpu=500m --expose --port=80
```

```
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```


## TIPS ##

#### List all containers in all namespaces


```
kubectl get pods --all-namespaces -o jsonpath="{..image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
```

```
kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
sort
```
