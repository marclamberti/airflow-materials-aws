#!/bin/bash

# Permissions and roles
aws iam delete-role-policy --role-name AirflowCodePipelineServiceRole --policy-name codepipeline-access 
aws iam delete-role --role-name AirflowCodePipelineServiceRole
aws iam delete-role-policy --role-name AirflowCodeBuildServiceRole --policy-name codebuild-access 
aws iam delete-role --role-name AirflowCodeBuildServiceRole

# CHANGE THE NAME OF THE BUCKET WITH YOURS
aws s3 rb s3://airflow-dev-codepipeline-artifacts --force
aws s3 rb s3://airflow-staging-codepipeline-artifacts --force
aws s3 rb s3://airflow-prod-codepipeline-artifacts --force

# Helm Charts
helm delete --namespace dev airflow-dev
helm delete --namespace staging airflow-staging
helm delete --namespace prod airflow-prod

# CodePipelines
aws cloudformation delete-stack --stack-name=airflow-dev-pipeline
aws cloudformation delete-stack --stack-name=airflow-staging-pipeline
aws cloudformation delete-stack --stack-name=airflow-prod-pipeline

# ECR
aws ecr delete-repository --force --repository-name=airflow-eks-docker-dev
aws ecr delete-repository --force --repository-name=airflow-eks-docker-staging
aws ecr delete-repository --force --repository-name=airflow-eks-docker-master

# EKS
# This can take up to 15 minutes
eksctl delete cluster --wait --name=airflow