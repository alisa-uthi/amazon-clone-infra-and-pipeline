locals {
  source_base_url = "github.com/alisa-uthi/aws-terraform-modules.git//s3-bucket"

  # Load the relevant env.hcl file based on where terragrunt was invoked. This works because find_in_parent_folders
  # always works at the context of the child configuration.
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common   = local.env_vars.locals

  common_tags = {
    Project     = local.common.project_name
    Environment = local.common.env
  }
}

inputs = {
  tags = local.common_tags
}

