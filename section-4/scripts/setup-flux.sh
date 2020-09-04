#!/bin/bash

if [ "$1" == "" ]; then
    echo "You must pass your git username"
    exit 1
fi

GIT_USERNAME=$1

# Installing Flux
# create the flux Kubernetes namespace
kubectl create namespace flux

# add the Flux chart repository to Helm and install Flux.
helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux \
--set git.url=git@github.com:$GIT_USERNAME/airflow-eks-config \
--namespace flux

helm upgrade -i helm-operator fluxcd/helm-operator --wait \
--namespace flux \
--set git.ssh.secretName=flux-git-deploy \
--set git.pollInterval=1m \
--set chartsSyncInterval=1m \
--set helm.versions=v3