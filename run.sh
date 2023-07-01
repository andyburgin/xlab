#!/usr/bin/env bash

set -e

pro=$(dpkg --print-architecture)
terraform_version="1.2.5"

echo Installing and starting Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-${pro}
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

pushd /vagrant/

kind create cluster --config kind-config.yaml --name kind-xlab-interview

echo Installing yq to interact with YAML config
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${pro}
sudo chmod a+x /usr/local/bin/yq

popd
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

echo Configure config values to configure terraform provider
kubectl config view --minify --flatten > clusterconfig.yaml
host=$(yq '.clusters[].cluster.server' clusterconfig.yaml)
clustercert=$(yq '.clusters[].cluster.certificate-authority-data' clusterconfig.yaml)
clientcert=$(yq '.users[].user.client-certificate-data' clusterconfig.yaml)
clientkey=$(yq '.users[].user.client-key-data' clusterconfig.yaml)

echo Installing terraform onto machine...
mkdir -p "${HOME}/bin"
sudo apt-get update && sudo apt-get install -y unzip jq
pushd "${HOME}/bin"

wget -q "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_${pro}.zip"
unzip -q -o "terraform_${terraform_version}_linux_${pro}.zip"
. "${HOME}/.profile"
popd

echo Applying terraform script...

pushd /vagrant/tf/
terraform init -upgrade
terraform apply  --var="host=$host" --var="cluster_cert=$clustercert" \
                --var="client_cert=$clientcert" --var="client_key=$clientkey" -auto-approve

