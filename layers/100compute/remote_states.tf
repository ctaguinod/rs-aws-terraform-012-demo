###############################################################################
# Terraform Remote State 
###############################################################################
# _main
data "terraform_remote_state" "main_state" {
  backend = "local"

  config = {
    path = "../_main/terraform.tfstate"
  }
}

# 000base
data "terraform_remote_state" "base_network" {
  backend = "s3"

  config = {
    bucket = local.s3_terraform_bucket
    key    = "000base/terraform.tfstate"
    region = var.region
  }
}

###############################################################################
# Locals
###############################################################################
locals {
  s3_terraform_bucket     = data.terraform_remote_state.main_state.outputs.s3_terraform.bucket_id
  vpc_id                  = data.terraform_remote_state.base_network.outputs.base_network.vpc_id
  private_subnets         = data.terraform_remote_state.base_network.outputs.base_network.private_subnets
  public_subnets          = data.terraform_remote_state.base_network.outputs.base_network.public_subnets
  PrivateAZ1              = data.terraform_remote_state.base_network.outputs.base_network.private_subnets[0]
  PrivateAZ2              = data.terraform_remote_state.base_network.outputs.base_network.private_subnets[1]
  PublicAZ1               = data.terraform_remote_state.base_network.outputs.base_network.public_subnets[0]
  PublicAZ2               = data.terraform_remote_state.base_network.outputs.base_network.public_subnets[1]
  internal_hosted_zone_id = data.terraform_remote_state.base_network.outputs.internal_zone.internal_hosted_zone_id
  internal_hosted_name    = data.terraform_remote_state.base_network.outputs.internal_zone.internal_hosted_name
  notification_topic      = data.terraform_remote_state.base_network.outputs.sns_topic.topic_arn
}

###############################################################################
# Remote State Output
###############################################################################

output "remote_state" {
  value = <<EOF

## main_state

| main_state | Value |
|---|---|
| s3_terraform_bucket | ${local.s3_terraform_bucket} |

## base_network

| Base Network | Value |
|---|---|
| vpc_id | ${local.vpc_id} |
| PrivateAZ1 | ${local.PrivateAZ1} |
| PrivateAZ1 | ${local.PrivateAZ1} |
| PublicAZ1 | ${local.PublicAZ1} |
| PublicAZ2 | ${local.PublicAZ2} |
| internal_hosted_zone_id | ${local.internal_hosted_zone_id} |
| internal_hosted_name | ${local.internal_hosted_name} |
| notification_topic | ${local.notification_topic} |

EOF

  description = "Remote State Summary `terraform output remote_states` "
}
