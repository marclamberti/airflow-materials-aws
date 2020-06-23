#!/bin/bash

# Update packages of the instance
sudo yum -y update

# Create a python virtual environment
python -m venv .sandbox

# Active the python virtual environment
source .sandbox/bin/activate

# Upgrade pip
pip install --upgrade pip

# Download and extract the latest release of eksctl with the following command.
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.21.0-rc.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# Move the extracted binary to /usr/local/bin.
sudo mv /tmp/eksctl /usr/local/bin

# Test that your installation was successful with the following command.
eksctl version

# Download the latest release of Kubectl with the command 
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.2/bin/linux/amd64/kubectl

# Make the kubectl binary executable.
chmod +x ./kubectl

# Move the binary in to your PATH.
sudo mv ./kubectl /usr/local/bin/kubectl

# Test to ensure the version you installed is up-to-date:
kubectl version --client

# Install Helm3
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Check the version
helm version --short

# Download the stable repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Add bash completion for helm
sudo yum install -y bash-completion
source <(helm completion bash)

# Config git
git config --global user.name "airflow-workstation"
# change the name by airflow-workstation and keep the email. Save and exit the file.