#!/bin/bash

bucket_name=$1
key=$2
region=$3
dynamodb_table=$4

# Generate Terraform configuration
cat << EOF > backend.tf
terraform {
  backend "s3" {
    bucket = "$bucket_name"
    key    = "$key/terraform.tfstate"
    region = "$region"
    dynamodb_table = "$dynamodb_table"
    encrypt = true
  }
}
EOF

echo "Terraform backend configuration generated in backend.tf"
