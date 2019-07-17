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

output internal_zone {
  description = "Route 53 Internal Zone"
  value       = module.internal_zone
}