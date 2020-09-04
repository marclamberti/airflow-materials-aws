#!/bin/bash

GIT_USERNAME=$1
GIT_TOKEN=$2
S3_BUCKET_NAME=$3

# Create the S3 bucket for the CodePipeline artifacts - This bucket must be globally unique so set your own
aws s3 mb s3://$S3_BUCKET_NAME

# Create IAM roles and add iniline policies so that CodePipeline can interact with EKS through kubectl
aws iam create-role --role-name AirflowCodePipelineServiceRole --assume-role-policy-document file://airflow-materials-aws/section-6/code-pipeline/cpAssumeRolePolicyDocument.json
aws iam put-role-policy --role-name AirflowCodePipelineServiceRole --policy-name codepipeline-access --policy-document file://airflow-materials-aws/section-6/code-pipeline/cpPolicyDocument.json
aws iam create-role --role-name AirflowCodeBuildServiceRole --assume-role-policy-document file://airflow-materials-aws/section-6/code-pipeline/cbAssumeRolePolicyDocument.json
aws iam put-role-policy --role-name AirflowCodeBuildServiceRole --policy-name codebuild-access --policy-document file://airflow-materials-aws/section-6/code-pipeline/cbPolicyDocument.json

# Create the AWS CodePipeline using CloudFormation (This doesn't deploy the image as Flux handles it)
aws cloudformation create-stack --stack-name=airflow-dev-pipeline --template-body=file://airflow-materials-aws/section-6/code-pipeline/airflow-dev-pipeline.cfn.yml --parameters ParameterKey=GitHubUser,ParameterValue=$GIT_USERNAME ParameterKey=GitHubToken,ParameterValue=$GIT_TOKEN ParameterKey=GitSourceRepo,ParameterValue=airflow-eks-docker ParameterKey=GitBranch,ParameterValue=dev
