#!/bin/bash
sudo docker rm -f $(docker ps -qa)
sudo docker rmi -f $(docker images -q)
sudo docker volume rm $(docker volume ls -q)
for mount in $(mount | grep tmpfs | grep '/var/lib/kubelet' | awk '{ print $3 }') /var/lib/kubelet /var/lib/rancher; do sudo umount $mount; done
cleanupdirs="/etc/ceph /etc/cni /etc/kubernetes /opt/cni /run/secrets/kubernetes.io /run/calico /run/flannel /var/lib/calico /var/lib/etcd /var/lib/cni /var/lib/kubelet /var/lib/rancher/rke/log /var/log/containers /var/log/kube-audit /var/log/pods /var/run/calico"
for dir in $cleanupdirs; do
  echo "Removing $dir"
  sudo rm -rf $dir
done
# removing /opt/rke - snapshots
sudo iptables -F
sudo iptables -t nat -F
sudo systemctl restart docker