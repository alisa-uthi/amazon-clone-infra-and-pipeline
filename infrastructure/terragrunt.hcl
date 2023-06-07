# Ref: https://terragrunt.gruntwork.io/docs/features/keep-your-terragrunt-architecture-dry/#keep-your-terragrunt-architecture-dry

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite"
  }

  config = {
    role_arn = "arn:aws:iam::447931064005:role/terraform"
    bucket   = "alisauthi-terraform-state"

    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # dynamodb_table = "terraform-lock-table"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
provider "aws" {
    region  = "us-east-1"

    assume_role {
        role_arn = "arn:aws:iam::447931064005:role/terraform"
    }
}
EOF
}