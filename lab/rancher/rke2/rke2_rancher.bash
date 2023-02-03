#!/bin/bash

green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green} ####### This applies only to CertManager (not owned certs) ######${normal} \n"
curl -s https://raw.githubusercontent.com/rancher/rke/release/v1.3/data/data.json| grep v1.2 | grep rke2 |sed 's/"//g'|awk '{print $2}'|sort
printf "\n"
printf "${green}RKE2 Version: ${normal}"
read RKE2_VERSION
printf "${green}TLS SANS: ${normal}"
read RKE2_TLS_SANS
printf "${green}Rancher hostname/URL: ${normal}"
read RANCHER_HOSTNAME
printf "${green}Rancher Repo (stable/latest): ${normal}"
read RANCHER_REPO     
printf "${green}Rancher version: ${normal}"
read RANCHER_VERSION
printf "${green}CertManager version (e.g. v1.5.1 - Rancher 2.5.x / v1.7.1 - Rancher 2.6.x): ${normal}"
read CERTMANAGER_VERSION

export RKE2_VERSION
export RKE2_TLS_SANS
export RANCHER_REPO
export RANCHER_VERSION
export RANCHER_HOSTNAME
export CERTMANAGER_VERSION

printf "${green}Installing RKE2...${normal} \n"
curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh -
systemctl enable rke2-server

mkdir -p /etc/rancher/rke2/
cat <<EOF > config.sample
tls-san:
  - $RKE2_TLS_SANS
EOF
envsubst < config.sample > /etc/rancher/rke2/config.yaml
systemctl start rke2-server

printf "${green}Downloading Helm 3.11.0...${normal} \n"
curl -sLO https://get.helm.sh/helm-v3.11.0-linux-amd64.tar.gz
tar xzf helm-v3.11.0-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm

printf "${green}Setting KUBECONFIG...${normal} \n"
cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
source <(kubectl completion bash)

###
printf "${green}Adding rancher helm repo ...${normal} \n"
helm repo add rancher-$RANCHER_REPO https://releases.rancher.com/server-charts/$RANCHER_REPO
printf "${green}Creating cattle-system namespace ...${normal} \n"
kubectl create namespace cattle-system
printf "${green}Creating cert-manager CRDs ...${normal} \n"
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$CERTMANAGER_VERSION/cert-manager.crds.yaml
printf "${green}Adding cert-manager repo ...${normal} \n"
helm repo add jetstack https://charts.jetstack.io
helm repo update
printf "${green}Helm installing cert-manager ...${normal} \n"
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version $CERTMANAGER_VERSION
####
printf "${green}Sleeping 120s ...${normal} \n"
sleep 120
printf "${green}Helm installing rancher ...${normal} \n"
helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION


#
# kubectl create namespace cattle-system
# kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=cert/fullchain1.pem --key=cert/privatekey.pem
# helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher26.prateslabs.com.br --set bootstrapPassword=**** --set ingress.tls.source=secret --version 2.6.3
#

#
# helm get values rancher -n cattle-system > values.yml
# helm upgrade rancher rancher-stable/rancher -n cattle-system --values values.yml --version 2.5.11
#