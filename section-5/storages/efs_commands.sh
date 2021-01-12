#!/bin/bash

# getting the cluster name
CLUSTER_NAME=$(eksctl get cluster | awk '{print $1 }' | sed -n '2p')

# getting the VPC ID where nodes are deployed
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)

# getting IPv4 CIDR block associated with that VPC
CIDR_BLOCK=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[].CidrBlock" --output text)

echo "Cluster name is $CLUSTER_NAME and VPC ID is $VPC_ID having CIDR block of $CIDR_BLOCK"
# creating a security group with the mount targets
MOUNT_TARGET_GROUP_NAME="eks-efs-group"
MOUNT_TARGET_GROUP_DESC="NFS access to EFS from EKS"
MOUNT_TARGET_GROUP_ID=$(aws ec2 create-security-group --group-name $MOUNT_TARGET_GROUP_NAME --description "$MOUNT_TARGET_GROUP_DESC" --vpc-id $VPC_ID | jq --raw-output '.GroupId')
# check in aws console that the security group has been well created

echo "Security group $MOUNT_TARGET_GROUP_ID has been created" && sleep 1
# adding ingress rule to allow all inbound traffic using NFS protocol on port 2049 
# from IP addresses that belong to the CIDR block of the EKS cluster VPC
# port 2049 is the port by default for NFS
aws ec2 authorize-security-group-ingress --group-id $MOUNT_TARGET_GROUP_ID --protocol tcp --port 2049 --cidr $CIDR_BLOCK

# create the EFS file system
FILE_SYSTEM_ID=$(aws efs create-file-system | jq --raw-output '.FileSystemId')

echo "EFS with id $FILE_SYSTEM_ID has been created" && sleep 1
# check the LifeCycleState of the file system using the following command and wait until it changes from creating to available before you proceed to the next step.
until aws efs describe-file-systems --file-system-id $FILE_SYSTEM_ID; do sleep 1 ; done

# we need to mount the EFS file system in each private subnet in each availability zone
# identifies the private subnets in the cluster VPC and creates a mount target
# in each subnet as well as associtate that mount target with the security group created
# before
TAG1=tag:kubernetes.io/cluster/$CLUSTER_NAME
TAG2=tag:kubernetes.io/role/internal-elb

subnets=$(aws ec2 describe-subnets --filters "Name=$TAG1,Values=shared" "Name=$TAG2,Values=1" | jq --raw-output '.Subnets[].SubnetId')

for subnet in ${subnets[@]}
do
echo "creating mount target in " $subnet
aws efs create-mount-target --file-system-id $FILE_SYSTEM_ID --subnet-id $subnet --security-groups $MOUNT_TARGET_GROUP_ID
done
