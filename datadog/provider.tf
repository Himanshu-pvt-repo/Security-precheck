terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
  region = var.aws_region
}

# Configure the Datadog provider for pipeline
provider "datadog" {
  app_key  = var.datadog_app_key
  api_key  = var.datadog_api_key
  alias    = "datadog-master"
  validate = false
}

# Configure the Datadog provider for account
provider "datadog" {
  app_key  = var.datadog_app_key
  api_key  = var.enable_datadog_integration == true ? module.datadog-key[0].datadog_api_key : var.datadog_api_key
  alias    = "datadog-account"
  validate = false
}
