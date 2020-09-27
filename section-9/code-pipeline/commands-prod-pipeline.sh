# Path to the template
TEMPLATE=file://airflow-materials-aws/section-9/code-pipeline/airflow-prod-pipeline.cfn.yml

# Update the stack
aws cloudformation create-stack --stack-name=airflow-prod-pipeline \
    --template-body=$TEMPLATE \
    --parameters ParameterKey=EksClusterName,ParameterValue=airflow \
    ParameterKey=KubectlRoleName,ParameterValue=AirflowCodeBuildServiceRole \
    ParameterKey=GitHubUser,ParameterValue=marclamberti \
    ParameterKey=GitHubToken,ParameterValue=cb53803446b0968e132e2e8ff729c7596fb0d7c8 \
    ParameterKey=GitSourceRepo,ParameterValue=airflow-eks-docker \
    ParameterKey=GitBranch,ParameterValue=master