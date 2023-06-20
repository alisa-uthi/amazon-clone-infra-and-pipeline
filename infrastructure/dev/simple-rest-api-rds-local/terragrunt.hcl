include "root" {
  path = find_in_parent_folders()
}

include "common_inputs" {
  path   = "${get_terragrunt_dir()}/../../_env/rds.hcl"
  expose = true
}

terraform {
  source = "${include.common_inputs.locals.source_base_url}?ref=rds-v0.0.1"

  extra_arguments "common_var" {
    commands  = get_terraform_commands_that_need_vars()
    arguments = ["-var-file=./terraform.tfvars"]
  }
}

locals {
  env_vars          = include.common_inputs.locals.common
  microservice_name = "simple-rest-api"
}

# Custom input configuration per environment (if any)
inputs = {
  #### Security Group ####
  security_group_name        = "${local.microservice_name}-sg-${local.env_vars.env}"
  security_group_description = "${local.microservice_name} Security Group"
  vpc_id                     = "vpc-010177aadff96b35a" # VPC ID of kubernetes cluster

  ingress_rules = [
    {
      description        = "(Temporary) Allow ALL"
      from_port          = 3306
      to_port            = 3306
      protocol           = "tcp"
      cidr_blocks        = ["0.0.0.0/0"]
    }
  ]

  egress_rules = []

  #### DB Instance ####
  # See parameter for each engine here: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  allocated_storage           = 5
  identifier                  = local.microservice_name
  db_name                     = "myuser"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t3.micro"
  username                    = "simplerestuser"
  port                        = 3306
  manage_master_user_password = false
  deletion_protection         = false
  skip_final_snapshot         = true
  publicly_accessible         = true

  #### DB Subnet Group ####
  db_subnet_group_name        = "${local.microservice_name}-${local.env_vars.env}"
  db_subnet_group_description = "${local.microservice_name}-${local.env_vars.env}"
  subnet_ids                  = ["subnet-04a37c26927617fa9", "subnet-0abe795ea322a2757"] # Public Subnet ID of kubernetes cluster
}