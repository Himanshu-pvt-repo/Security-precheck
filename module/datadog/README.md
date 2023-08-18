# AWS Datadog Integration

## Overview
This AWS Datadog Integration Terraform module seamlessly configures and deploys the integration between Amazon Web Services (AWS) resources and the Datadog monitoring and analytics platform. It automates the setup of metric collection of aws resources which provides insights into your AWS environment through Datadog's powerful monitoring capabilities.

![datadog drawio](https://media.git.i.mercedes-benz.com/user/23346/files/be2ad2f0-d19a-4943-855b-744f1b673aaf)

In this approach, a single set of Master credentials for Datadog is employed. From these credentials, distinct API keys are generated for individual accounts. These separate keys are then utilized to integrate with Datadog for their respective accounts.

Please review the following modules to get more understanding.

* [Datadog integration](/modules/datadog/datadog-aws)
* [Datadog api-key creation](/modules/datadog/datadog-key)


## Quick start

To try these templates, you must have Terraform installed (minimum version: `1.0.0`)

* In order to utilize the module, it's necessary to establish two Terraform Datadog providers. The initial provider is employed for generating the API key, which is subsequently passed to the second provider. This second provider is responsible for crafting the Datadog integration using the freshly generated API key.


```hcl
# Configure the Datadog provider for pipeline
provider "datadog" {
  app_key = var.datadog_app_key
  api_key = var.datadog_api_key
  alias   = "datadog-master"
  validate = false
}

# Configure the Datadog provider for member account
provider "datadog" {
  app_key = var.datadog_app_key
  api_key = var.enable_datadog_integration == true ? module.datadog-key[0].datadog_api_key : var.datadog_api_key
  alias   = "datadog-account"
  validate = false
}
```


* After setting up the Datadog provider for both the Master and member accounts, we can then make use of these providers to invoke the module for the purpose of generating API keys and creating integrations.

```hcl
# -------------------------------------------------------------------------------------------------
# AWS and DataDog Integration
# -------------------------------------------------------------------------------------------------

module "datadog" {

  providers = {
    datadog = datadog.datadog-account
  }
  depends_on = [module.datadog-key]
  count      = var.enable_datadog_integration == true ? 1 : 0
  source     = "../../modules/datadog/datadog-aws"
  account_id = data.aws_caller_identity.current.account_id
  host_tags  = concat(["aws_account:${data.aws_caller_identity.current.account_id}"], var.datadog_host_tags)
  dd_account_id = "464622532012"
}

module "datadog-key" {

  providers = {
    datadog = datadog.datadog-master
  }
  count             = var.enable_datadog_integration == true ? 1 : 0
  source            = "../../modules/datadog/datadog-key"
  datadog_api_key_name = var.datadog_api_key_name
}
```


* This solution requires the use of Master credentials in order to be implemented. To ensure a secure transmission, we have chosen to store these credentials within GitHub secrets. However, for testing purposes of this module, you have the option to export these credentials using the provided commands through environmental variables.

```bash
 export DATADOG_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
 export DATADOG_APP_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Note** that there is an extra space before the `export:` this ensures that the command is NOT stored in shell history (assuming you have [HISTCONTROL](https://www.aplawrence.com/Linux/bash_history.html) configured correctly—e.g., set to `ignoreboth`—in your shell).

* Run `terraform init` to instruct Terraform to perform initialization steps.
* Run `terraform plan -var "datadog_api_key=$DATADOG_API_KEY" -var "datadog_app_key=$DATADOG_APP_KEY"` to confirm that Terraform will create a reasonable set of resources.
* Run `terraform apply -var "datadog_api_key=$DATADOG_API_KEY" -var "datadog_app_key=$DATADOG_APP_KEY"` to create the necessary resources and activate Audit Manager with the frameworks mentioned above.

## Conclusion

You can find more range of options available for Datadog resources with terraform [here](https://registry.terraform.io/providers/DataDog/datadog/latest/docs) or check the [Managing Datadog with Terraform](https://www.datadoghq.com/blog/managing-datadog-with-terraform) blog.
