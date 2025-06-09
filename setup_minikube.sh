#!/bin/bash

# uncomment below to debug
set -x

# Update the system
sudo yum update -y

# Install Docker
echo "Upgrade Amazon linux to the latest version"
sudo dnf upgrade --releasever=2023.5 -y
#dnf upgrade --releasever=2023.5.20240916 -y
sudo dnf install docker -y
sudo service docker restart
sudo systemctl enable docker
#sudo newgrp docker

# Install dependencies for Minikube
sudo dnf install -y --allowerasing curl wget git telnet

# Install conntrack (required for Minikube)
sudo dnf install -y conntrack

# Install crictl - check latest version here: https://github.com/kubernetes-sigs/cri-tools/releases
VERSION="v1.30.0"
OS="Linux"
ARCH="amd64"
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-${OS}-${ARCH}.tar.gz
sudo tar zxvf crictl-${VERSION}-${OS}-${ARCH}.tar.gz -C /usr/local/bin
sudo ls -l  /usr/local/bin/crictl

# Install cri-dockerd - check latest version here: https://github.com/Mirantis/cri-dockerd/releases
VERSION="0.3.1"
curl -LO https://github.com/Mirantis/cri-dockerd/releases/download/v${VERSION}/cri-dockerd-${VERSION}.amd64.tgz
tar -xvf cri-dockerd-${VERSION}.amd64.tgz
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/


# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install containernetworking-plugins for none driver
CNI_PLUGIN_VERSION="v1.7.1"
CNI_PLUGIN_TAR="cni-plugins-linux-amd64-$CNI_PLUGIN_VERSION.tgz" # change arch if not on amd64
CNI_PLUGIN_INSTALL_DIR="/opt/cni/bin"
curl -LO "https://github.com/containernetworking/plugins/releases/download/$CNI_PLUGIN_VERSION/$CNI_PLUGIN_TAR"
sudo mkdir -p "$CNI_PLUGIN_INSTALL_DIR"
sudo tar -xf "$CNI_PLUGIN_TAR" -C "$CNI_PLUGIN_INSTALL_DIR"
rm "$CNI_PLUGIN_TAR"

# Cleanup any previous instance
minikube delete

# Add current user to docker group - we need this for docker container run
sudo usermod -aG docker $USER

# This block is avoid dropping to shell - newgrp does that!
newgrp docker <<EONG
echo "## Inside docker group"

# Start Minikube (using none driver for virtual machines)
minikube start --driver=docker
# sudo minikube start --driver=none
# minikube start  #autodetect driver

echo "Finished minikube command"
EONG
echo "Back to the main script ##"

# wait till launch
sleep 10

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Enable kubectl bash completion
sudo echo 'source <(kubectl completion bash)' >>~/.bashrc
sudo echo 'alias k=kubectl' >>~/.bashrc
sudo echo 'complete -F __start_kubectl k' >>~/.bashrc

# Add ec2-user to docker group and restart shell session
sudo usermod -aG docker ec2-user
#sudo newgrp docker

# Ensure Minikube status
minikube status

# Basic kubectl commands (optional to verify installation)
kubectl version --client

# get nodes
kubectl get nodes

# get namespaces
kubectl get ns

# get all
kubectl get all
