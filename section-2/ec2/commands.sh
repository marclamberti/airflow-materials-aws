#!/bin/bash

# Update packages of the instance
sudo yum -y update

# Install git
sudo yum -y install git

# Install Python 3
sudo yum -y install python3
python3 -V

# Create a python virtual environment
python3 -m venv .sandbox

# Active the python virtual environment
source .sandbox/bin/activate

# Upgrade pip
pip install --upgrade pip

# Download AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip
unzip awscliv2.zip

# Install
sudo ./aws/install

# Check that the version is aws at least >2
aws --version

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

# Configure aws
aws configure
# enter you AWS ACCESS KEY ID/ SECRET ID/ Region / json

# Install Helm3
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Check the version
helm version --short

# Download the stable repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Add bash completion for helm
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)

# Config git
git config --global --edit
# change the name by airflow-workstation and keep the email. Save and exit the file.