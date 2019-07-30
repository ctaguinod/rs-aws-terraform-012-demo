###############################################################################
# Base Network Output
###############################################################################
output "base_network" {
  description = "base_network Module Output"
  value       = module.base_network
}

###############################################################################
# NAT Gateways 
###############################################################################

# Nat GW1
data "aws_nat_gateway" "NatAZ1" {
  subnet_id = module.base_network.public_subnets[0]
}

output "NatPublicIPAZ1" {
  description = "The NAT gateway Public IP in Public AZ1"
  value       = data.aws_nat_gateway.NatAZ1.public_ip
}

output "NatPrivateIPAZ1" {
  description = "The NAT gateway private IP in Public AZ1"
  value       = data.aws_nat_gateway.NatAZ1.private_ip
}

# Nat GW1
data "aws_nat_gateway" "NatAZ2" {
  subnet_id = module.base_network.public_subnets[1]
}

output "NatPublicIPAZ2" {
  description = "The NAT gateway Public IP in Public AZ2"
  value       = data.aws_nat_gateway.NatAZ2.public_ip
}

output "NatPrivateIPAZ2" {
  description = "The NAT gateway private IP in Public AZ2"
  value       = data.aws_nat_gateway.NatAZ2.private_ip
}

###############################################################################
# Route53 Internal Zone Output
###############################################################################
output internal_zone {
  description = "Route 53 Internal Zone"
  value       = module.internal_zone
}

###############################################################################
# SNS Output
###############################################################################
output "sns_topic" {
  description = "SNS Topic"
  value       = module.sns_topic
}

###############################################################################
# Summary Output
# terraform output summary
###############################################################################

output "summary" {
  value = <<EOF

## Outputs - 000base layer

| Base Network | Value |
|---|---|
| vpc_id | ${module.base_network.vpc_id} |
| PrivateAZ1 | ${module.base_network.private_subnets[0]} |
| PrivateAZ1 | ${module.base_network.private_subnets[1]} |
| PublicAZ1 | ${module.base_network.public_subnets[0]} |
| PublicAZ2 | ${module.base_network.public_subnets[1]} |

| Nat Gateway | Value |
|---|---|
| NatPublicIPAZ1 | ${data.aws_nat_gateway.NatAZ1.public_ip} |
| NatPrivateIPAZ1 | ${data.aws_nat_gateway.NatAZ1.private_ip} |
| NatPublicIPAZ2 | ${data.aws_nat_gateway.NatAZ2.public_ip} |
| NatPrivateIPAZ2 | ${data.aws_nat_gateway.NatAZ2.private_ip} |

| Route53 | Value |
|---|---|
| internal_hosted_zone_id | ${module.internal_zone.internal_hosted_zone_id} |
| internal_hosted_name | ${module.internal_zone.internal_hosted_name} |


| SNS | Value |
|---|---|
| notification_topic | ${module.sns_topic.topic_arn} | 

EOF

  description = "Base Network Layer Outputs Summary `terraform output summary` "
}

###############################################################################
# State Import Example
# terraform output state_import_example
###############################################################################

output "state_import_example" {
  description = "An example to use this layers state in another."

  value = <<EOF


  data "terraform_remote_state" "000base" {
    backend = "s3"

    config = {
      bucket  = "${data.terraform_remote_state.main_state.outputs.state_bucket_id}"
      key     = "terraform.${lower(var.environment)}.000base.tfstate"
      region  = "${data.terraform_remote_state.main_state.outputs.state_bucket_region}"
      encrypt = "true"
    }
  }
EOF
}
