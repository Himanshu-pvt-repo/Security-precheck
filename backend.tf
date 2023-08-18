terraform {
  backend "s3" {
    bucket = "s3-datadog"
    key    = "datadog/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "datadog_table"
    encrypt = true
  }
}
