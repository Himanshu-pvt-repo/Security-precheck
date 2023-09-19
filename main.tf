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
  app_key = var.datadog_app_key
  api_key = var.datadog_api_key
  alias   = "datadog-provider"
}



module "bulk_monitor" {

  providers = {
    datadog = datadog.datadog-provider
  }
  source               = "./modules/bulk_monitor"
  filepath             = "monitor.csv"
}
