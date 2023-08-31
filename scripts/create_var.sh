#!/bin/bash

datadog_api_key_name=$1
enable_datadog_integration=$2
datadog_host_tags=$3
datadog_api_key=$4
datadog_app_key=$5

# Generate Terraform configuration
cat << EOF > terraform.tfvars
datadog_api_key_name = "$datadog_api_key_name"
enable_datadog_integration = $enable_datadog_integration
datadog_host_tags=$datadog_host_tags
datadog_api_key= "$datadog_api_key"
datadog_app_key= "$datadog_app_key"
EOF

echo "Terraform Values configuration generated in terraform.tfvars"