locals {
  source_base_url = "github.com/alisa-uthi/aws-terraform-modules.git//vpc"

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common   = local.env_vars.locals

  common_tags = {
    Project     = local.common.project_name
    Environment = local.common.env
    // This is so kops knows that the VPC resources can be used for k8s
    "kubernetes.io/cluster/${local.common.kubernetes_cluster_name}" = "shared"
  }
}

# Common configurations
inputs = {
  env                     = local.common.env
  region                  = local.common.region
  availability_zones      = local.common.availability_zones
  kubernetes_cluster_name = local.common.kubernetes_cluster_name

  name = "vpc-${local.common.env}"
  tags = local.common_tags
  cidr = "10.0.0.0/16"
  vpc_tags = {
    Name = "vpc-${local.common.env}"
  }

  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnet_names = [for i, v in local.common.availability_zones : "private-subnet${i}-${local.common.env}-${v}"]
  public_subnet_names  = [for i, v in local.common.availability_zones : "public-subnet${i}-${local.common.env}-${v}"]
  private_subnet_tags = {
    Name                              = "private-subnet-${local.common.env}-${local.common.region}"
    "kubernetes.io/role/internal-elb" = true
  }
  public_subnet_tags = {
    Name                     = "public-subnet-${local.common.env}-${local.common.region}"
    "kubernetes.io/role/elb" = true
  }

  private_route_table_tags = {
    Name = "private-route-table-${local.common.env}-${local.common.region}"
  }
  public_route_table_tags = {
    Name = "public-route-table-${local.common.env}-${local.common.region}"
  }

  igw_tags = {
    Name = "igw-${local.common.env}"
  }

  # nat_gateway_tags = {
  #   Name = "nat-${local.common.env}"
  # }
}