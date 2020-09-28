#!/bin/bash

MATERIALS=airflow-materials-aws

# SET YOUR values
GIT_USERNAME=marclamberti
GIT_TOKEN=cb53803446b0968e132e2e8ff729c7596fb0d7c8
S3_BUCKET_NAME_DEV=airflow-dev-codepipeline-artifacts
S3_BUCKET_NAME_STAGING=airflow-staging-codepipeline-artifacts

# ----------------------------- Start the EKS Cluster
eksctl create cluster -f $MATERIALS/cluster.yml

# ----------------------------- Create CI/CD pipelines
# S3 Buckets and ECRs are created from the pipelines

SCRIPT_CODE_PIPELINE_DEV=$MATERIALS/section-6/scripts/setup-codepipeline-dev.sh
chmod a+x $SCRIPT_CODE_PIPELINE_DEV
$SCRIPT_CODE_PIPELINE_DEV $GIT_USERNAME $GIT_TOKEN $S3_BUCKET_NAME_DEV

SCRIPT_CODE_PIPELINE_STAGING=$MATERIALS/section-7/scripts/setup-codepipeline-staging.sh
chmod a+x $SCRIPT_CODE_PIPELINE_STAGING
$SCRIPT_CODE_PIPELINE_STAGING $GIT_USERNAME $GIT_TOKEN $S3_BUCKET_NAME_STAGING

# ----------------------------- IAM for ingresses
SCRIPT_SETUP_INGRESS=$MATERIALS/section-7/scripts/setup-ingress.sh
chmod a+x $SCRIPT_SETUP_INGRESS
$SCRIPT_SETUP_INGRESS

# ----------------------------- Install Flux
# Install Flux and synchronize the git repo with all manifests in kubernetes
# Notice that you have to change the tag of the docker image 
# used in the airflow release dev since we removed the ECRs registries

SCRIPT_SETUP_FLUX=$MATERIALS/section-4/scripts/setup-flux.sh
chmod a+x $SCRIPT_SETUP_FLUX
$SCRIPT_SETUP_FLUX $GIT_USERNAME # CHANGE marclamberti by your Git username!

# Recreate the deploy key airflow-workstation-deploy-flux in the repo
# airflow-eks-config with the key generated below
fluxctl identity --k8s-fwd-ns flux