variable "account_id" {
  description = "aws_account_id"
  type        = string
  default     = null
}

variable "dd_account_id" {
  description = "datadog aws_account_id"
  type        = string
  default     = null
}

variable "excluded_regions" {
  type    = list(string)
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

variable "host_tags" {
  type    = list(string)
  default = []
}