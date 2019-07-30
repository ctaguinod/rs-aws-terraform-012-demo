
###############################################################################
#########################       000base Layer         #########################
###############################################################################

###############################################################################
# Providers
###############################################################################
provider "aws" {
  version             = "~> 2.0"
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}


locals {
  tags = {
    Environment     = "${var.environment}"
    ServiceProvider = "Rackspace"
  }
}

###############################################################################
# Terraform main config
# terraform block cannot be interpolated; sample provided as output of _main
# `terraform output remote_state_configuration_example`
###############################################################################
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    # Get S3 Bucket name from layer _main (`terraform output state_bucket_id`)
    bucket = "626499166183-build-state-bucket"
    # This key must be unique for each layer!
    key     = "terraform.development.000base.tfstate"
    region  = "ap-southeast-1"
    encrypt = "true"
  }
}

###############################################################################
# Terraform Remote State 
###############################################################################
data "terraform_remote_state" "main_state" {
  backend = "local"

  config = {
    path = "../../_main/terraform.tfstate"
  }
}

###############################################################################
# Base Network
# https://github.com/rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork
###############################################################################
locals {
  custom_tags = [
    {
      CustomTag1 = "CustomTagValue1"
      CustomTag2 = "CustomTagValue2"
    }
  ]

  private_subnet_tags = [
    {
      PrivateSubnetTag1 = "PrivateSubnetTagValue1"
      PrivateSubnetTag2 = "PrivateSubnetTagValue2"
    }
  ]

  public_subnet_tags = [
    {
      PublicSubnetTag1 = "PublicSubnetTagValue1"
      PublicSubnetTag2 = "PublicSubnetTagValue2"
    }
  ]
}

module "base_network" {
  source              = "github.com/rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=tf_0.12-upgrade"
  vpc_name            = var.vpc_name
  cidr_range          = var.cidr_range
  custom_azs          = var.custom_azs
  public_cidr_ranges  = var.public_cidr_ranges
  private_cidr_ranges = var.private_cidr_ranges
  build_nat_gateways  = var.build_nat_gateways
  environment         = var.environment
  az_count            = var.az_count
  # Custom Tags
  custom_tags         = local.custom_tags[0]
  private_subnet_tags = local.private_subnet_tags[0]
  public_subnet_tags  = local.public_subnet_tags[0]
}

###############################################################################
# Route53 Internal Zone
# https://github.com/rackspace-infrastructure-automation/aws-terraform-route53_internal_zone
###############################################################################
module "internal_zone" {
  source        = "github.com/rackspace-infrastructure-automation/aws-terraform-route53_internal_zone//?ref=tf_0.12-upgrade"
  target_vpc_id = module.base_network.vpc_id
  zone_name     = "${lower(var.environment)}.local"
  environment   = var.environment
}

###############################################################################
# SNS
###############################################################################
module "sns_topic" {
  source     = "github.com/rackspace-infrastructure-automation/aws-terraform-sns//?ref=tf_0.12-upgrade"
  topic_name = "${var.environment}-sns-topic"
}
