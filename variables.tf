variable "aws_region" {
  description = "DEPRECATED. The AWS Region where this VPC will exist. This variable is no longer used and only kept around for backwards compatibility. We now automatically fetch the region using a data source."
  type        = string
  default     = "us-east-1"
}


# ---------------------------------------------------------------------------------------------
# AWS-DataDog
# ---------------------------------------------------------------------------------------------

variable "enable_datadog_integration" {
  description = "set true to enable datadog intigration with aws"
  type        = bool
  default     = true
}

variable "datadog_app_key" {
  description = "datadog_app_key"
  type        = string
  default     = null
  sensitive = true
}

variable "datadog_api_key" {
  description = "datadog_api_key"
  type        = string
  default     = null
  sensitive = true
}

variable "excluded_regions" {
  type = list(string)
  default = [
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "af-south-1",
    "ap-east-1",
    "ap-south-1",
    "ap-south-2",
    "ap-northeast-3",
    "ap-northeast-2",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-southeast-3",
    "ap-southeast-4",
    "ap-northeast-1",
    "ca-central-1",
    "eu-central-1",
    "eu-central-2",
    "eu-west-1",
    "eu-west-2",
    "eu-south-1",
    "eu-south-2",
    "eu-west-3",
    "eu-north-1",
    "me-south-1",
    "me-central-1",
    "sa-east-1",
    "us-gov-east-1",
    "us-gov-west-1"
  ]
}

variable "datadog_host_tags" {
  type    = list(string)
  default = []
}

variable "datadog_api_key_name" {
  description = "datadog_api_key_name"
  type        = string
  default     = null
}
