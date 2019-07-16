###############################################################################
# Outputs
# terraform output terraform_remote_state_configuration_example
# terraform output terraform_remote_state_import_example
###############################################################################

output "terraform_remote_state_configuration_example" {
  value = <<EOF
  terraform {
    backend "s3" {
      # this key must be unique for each layer!
      key            = "000base/terraform.tfstate"
      bucket         = "rs-tfstate-${var.aws_account_id}-${var.region}"
      region         = "${var.region}"
      dynamodb_table = "terraform-state"
      encrypt        = "true"
    }
  }
EOF

  description = "Terraform block to put into the build layers"
}

output "terraform_remote_state_import_example" {
  value = <<EOF
  data "terraform_remote_state" "base_network" {
    backend = "s3"
    config = {
      bucket = "rs-tfstate-${var.aws_account_id}-${var.region}"
      region = "${var.region}"
    }
  }
EOF

  description = "Example how to use remote state from other layers"
}

###############################################################################
# Outputs
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


### NAT Gateways 
data "aws_nat_gateway" "NatAZ1" {
  subnet_id = module.base_network.public_subnets[0]
}

data "aws_nat_gateway" "NatAZ2" {
  subnet_id = module.base_network.public_subnets[1]
}

output "NatPublicIPAZ1" {
  description = "The NAT gateway Public IP in Public AZ1"
  value = data.aws_nat_gateway.NatAZ1.public_ip
}

output "NatPrivateIPAZ1" {
  description = "The NAT gateway private IP in Public AZ1"
  value = data.aws_nat_gateway.NatAZ1.private_ip
}

output "NatPublicIPAZ2" {
  description = "The NAT gateway Public IP in Public AZ2"
  value = data.aws_nat_gateway.NatAZ2.public_ip
}

output "NatPrivateIPAZ2" {
  description = "The NAT gateway private IP in Public AZ2"
  value = data.aws_nat_gateway.NatAZ2.private_ip
}