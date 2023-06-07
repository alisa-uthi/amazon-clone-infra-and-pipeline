include "root" {
  path = find_in_parent_folders()
}

include "common_inputs" {
  path   = "${get_terragrunt_dir()}/../../../_env/s3-bucket.hcl"
  expose = true
}

terraform {
  source = "${include.common_inputs.locals.source_base_url}?ref=s3-bucket-v0.0.1"
}

# Custom input configuration per environment (if any)
inputs = {
  bucket_name   = "${include.common_inputs.locals.common.env}-kubernetes-cluster-state"
  force_destroy = true
}