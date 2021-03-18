```
dnf install nfs-utils
mkdir /nfsshare
systemctl enable nfs-server
cp exports /etc/exports
systemctl start nfs-server
exportfs -va
```
