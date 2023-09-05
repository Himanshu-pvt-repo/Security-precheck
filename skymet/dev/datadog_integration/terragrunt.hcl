terraform {
  source = "git@git.i.mercedes-benz.com:MBUSA/ride-platform-tf-modules.git//datadog_integration/module?ref=feature/CPET-1938-refactor-dd-integration"  
}
include {
  path = find_in_parent_folders()
}
inputs = {
    datadog_api_key_name = "skymet-key"
    enable_datadog_integration = true
    datadog_host_tags = ["aws_account_name:example_account"]
    datadog_app_key = ""
    datadog_api_key = ""
 }
