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

data "aws_caller_identity" "current" {}

# Create a new Datadog API Key
resource "datadog_api_key" "api" {
  name = var.datadog_api_key_name
}
