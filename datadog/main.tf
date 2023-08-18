terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.26.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

# Configure the Datadog provider
provider "datadog" {
  app_key = var.datadog_app_key
  api_key = var.datadog_api_key
  alias   = "datadog-provider"
}

data "aws_caller_identity" "current" {}


# -------------------------------------------------------------------------------------------------
# AWS and DataDog Integration
# -------------------------------------------------------------------------------------------------

module "datadog" {

  providers = {
    datadog = datadog.datadog-account
  }
  depends_on    = [module.datadog-key]
  count         = var.enable_datadog_integration == true ? 1 : 0
  source        = "./module/datadog/datadog-aws"
  account_id    = data.aws_caller_identity.current.account_id
  host_tags     = concat(["aws_account:${data.aws_caller_identity.current.account_id}"], var.datadog_host_tags)
  dd_account_id = "464622532012"
}

module "datadog-key" {

  providers = {
    datadog = datadog.datadog-master
  }
  count                = var.enable_datadog_integration == true ? 1 : 0
  source               = "./module/datadog/datadog-key"
  datadog_api_key_name = var.datadog_api_key_name
}
