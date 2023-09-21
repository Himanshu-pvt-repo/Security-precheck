#!/bin/bash

datadog_app_key=$1
datadog_api_key=$2
filepath=$3

cat << EOF > main.tf
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.26.0"
    }
  }
}

# Configure the Datadog provider
provider "datadog" {
  app_key = "${datadog_app_key}"
  api_key = "${datadog_api_key}"
  alias   = "datadog-provider"
}

module "bulk_monitor" {
  providers = {
    datadog = datadog.datadog-provider
  }
  source               = "../modules/bulk_monitor"
  filepath             = "../${filepath}"
}
EOF
