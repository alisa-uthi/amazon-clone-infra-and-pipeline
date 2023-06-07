include "root" {
  path = find_in_parent_folders()
}

include "common_inputs" {
  path   = "${get_terragrunt_dir()}/../../../_env/vpc.hcl"
  expose = true
}

terraform {
  source = "${include.common_inputs.locals.source_base_url}?ref=vpc-v0.0.1"
}

# Custom input configuration per environment (if any)
# inputs = {}
