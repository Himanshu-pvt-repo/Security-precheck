locals {
  account_vars = read_terragrunt_config("account.hcl")
  account_name = local.account_vars.locals.account_name
  role_arn = local.account_vars.locals.role_arn
  region   = local.account_vars.locals.region
  env = local.account_vars.locals.env
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<new_EOF
provider "aws" {
  assume_role {
    role_arn = "${local.role_arn}"
  }
  region = "${local.region}"
}
new_EOF
}

# Generate backend configuration for remote state
remote_state {
  backend = "s3"
  config = {
    bucket         = "mbusa-remote-state"
    key            = "${local.account_name}/${path_relative_to_include()}/statefile.tfstate"
    region         = local.region
    dynamodb_table = "mbusa-remote-state"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
