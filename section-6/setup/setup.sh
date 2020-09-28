#!/bin/bash

MATERIALS=airflow-materials-aws
# CHANGE marclamberti by your Git username!
GIT_USERNAME=marclamberti

# Create the cluster
eksctl create cluster -f $MATERIALS/cluster.yml

SCRIPT_SETUP_FLUX=$MATERIALS/section-4/scripts/setup-flux.sh
chmod a+x $SCRIPT_SETUP_FLUX
$SCRIPT_SETUP_FLUX $GIT_USERNAME

fluxctl sync --k8s-fwd-ns flux

# If the command above failed, you migh need to
# recreate the deploy key airflow-workstation-deploy-flux in the repo
# airflow-eks-config with the key generated below
fluxctl identity --k8s-fwd-ns flux

# and execute fluxctl sync --k8s-fwd-ns flux again

