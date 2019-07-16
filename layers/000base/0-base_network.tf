###############################################################################
# Base Network
# https://github.com/rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork
###############################################################################

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
  custom_tags = {
    CustomTag1 = "CustomTagValue1"
    CustomTag2 = "CustomTagValue3"
  }
  private_subnet_tags = {
    PrivateSubnetTag1 = "PrivateSubnetTagValue1"
    PrivateSubnetTag2 = "PrivateSubnetTagValue2"
  }
  public_subnet_tags = {
    PublicSubnetTag1 = "PublicSubnetTagValue1"
    PublicSubnetTag1 = "PublicSubnetTagValue1"
  }
}

output "base_network" {
  description = "base_network Module Output"
  value       = module.base_network
}