# Create the S3 bucket for the CodePipeline artifacts - This bucket must be globally unique so set your own
aws s3 mb s3://airflow-dev-codepipeline-artifacts

# Create IAM roles and add iniline policies so that CodePipeline can interact with EKS through kubectl
aws iam create-role --role-name AirflowCodePipelineServiceRole --assume-role-policy-document file://airflow-materials-aws/section-6/code-pipeline/cpAssumeRolePolicyDocument.json
aws iam put-role-policy --role-name AirflowCodePipelineServiceRole --policy-name codepipeline-access --policy-document file://airflow-materials-aws/section-6/code-pipeline/cpPolicyDocument.json
aws iam create-role --role-name AirflowCodeBuildServiceRole --assume-role-policy-document file://airflow-materials-aws/section-6/code-pipeline/cbAssumeRolePolicyDocument.json
aws iam put-role-policy --role-name AirflowCodeBuildServiceRole --policy-name codebuild-access --policy-document file://airflow-materials-aws/section-6/code-pipeline/cbPolicyDocument.json

# open the flux pipeline to set the bucket name you created under "ArtifactStore"
vim airflow-materials-aws/code-pipeline/airflow-dev-pipeline.cfn.yml

# Create the AWS CodePipeline using CloudFormation (This doesn't deploy the image as Flux handles it)
aws cloudformation create-stack --stack-name=airflow-dev-pipeline --template-body=file://airflow-materials-aws/section-6/code-pipeline/airflow-dev-pipeline.cfn.yml --parameters ParameterKey=GitHubUser,ParameterValue=marclamberti ParameterKey=GitHubToken,ParameterValue=cb53803446b0968e132e2e8ff729c7596fb0d7c8 ParameterKey=GitSourceRepo,ParameterValue=airflow-eks-docker ParameterKey=GitBranch,ParameterValue=dev
