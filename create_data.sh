#!/bin/bash

account_name=$1
account_id=$2
region=$3
env=$4
datadog_api_key_name=$5
enable_datadog_integration=$6
datadog_host_tags=$7

mkdir -p ${account_name}/${env}/datadog_integration
cd ${account_name}/${env}/datadog_integration


# Generate Terraform configuration
cat << EOF > account.hcl
locals {
  account_name = "${account_name}"
  account_id = ${account_id}
  role_arn = "arn:aws:iam::${account_id}:role/TerraformAccessRole"
  region = "${region}"
  env = "${env}"
}
EOF

cat << EOF > terragrunt.hcl
terraform {
  source = "git::https://git.i.mercedes-benz.com/MBUSA/ride-platform-tf-modules.git//datadog_integration/module?ref=feature/CPET-1938-refactor-dd-integration"  
}
include {
  path = find_in_parent_folders()
}
inputs = {
    datadog_api_key_name = "$datadog_api_key_name"
    enable_datadog_integration = $enable_datadog_integration
    datadog_host_tags = $datadog_host_tags
}
EOF


cd .. && cat << EOF > terragrunt.hcl
locals {
  account_vars = read_terragrunt_config("account.hcl")
  account_name = local.account_vars.locals.account_name
  role_arn = local.account_vars.locals.role_arn
  region   = local.account_vars.locals.region
  env = local.account_vars.locals.env
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  assume_role {
    role_arn = "\${local.role_arn}"
  }
  region = "\${local.region}"
}
}

# Generate backend configuration for remote state
remote_state {
  backend = "s3"
  config = {
    bucket         = "now-platform-terraform-backend"
    key            = "\${local.account_name}/\${path_relative_to_include()}/statefile.tfstate"
    region         = local.region
    dynamodb_table = "now-platform-terraform-backend"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
EOF

echo "Terraform backend configuration generated in account.tf and terragrunt.tf"