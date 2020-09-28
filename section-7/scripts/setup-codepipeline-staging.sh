#!/bin/bash

GIT_USERNAME=$1
GIT_TOKEN=$2
S3_BUCKET_NAME=$3

# Patch aws-auth as we want to interact with helm in EKS from CodePipeline
ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
ROLE="    - rolearn: arn:aws:iam::$ACCOUNT_ID:role/AirflowCodeBuildServiceRole\n      username: build\n      groups:\n        - system:masters"
kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml
kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"

# Create the S3 bucket for the CodePipeline artifacts - This bucket must be globally unique so set your own
aws s3 mb s3://$S3_BUCKET_NAME

# Create the AWS CodePipeline using CloudFormation (This doesn't deploy the image as Flux handles it)
aws cloudformation create-stack --stack-name=airflow-staging-pipeline --template-body=file://airflow-materials-aws/section-6/code-pipeline/airflow-staging-pipeline.cfn.yml --parameters ParameterKey=EksClusterName,ParameterValue=airflow ParameterKey=KubectlRoleName,ParameterValue=AirflowCodeBuildServiceRole ParameterKey=GitHubUser,ParameterValue=$GIT_USERNAME ParameterKey=GitHubToken,ParameterValue=$GIT_TOKEN ParameterKey=GitSourceRepo,ParameterValue=airflow-eks-docker ParameterKey=GitBranch,ParameterValue=staging