#!/bin/bash

# EKS
# This can take up to 15 minutes
eksctl delete cluster --wait --name=airflow

# Don't forget to delete the EFS storage
# Services -> EFS -> Select the storage and click on Delete