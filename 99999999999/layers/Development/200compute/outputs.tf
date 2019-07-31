###############################################################################
# State Import Example
# terraform output state_import_example
###############################################################################
output "state_import_example" {
  description = "An example to use this layers state in another."

  value = <<EOF

  data "terraform_remote_state" "compute" {
    backend = "s3"

    config = {
      bucket  = "${data.terraform_remote_state.main_state.outputs.state_bucket_id}"
      key     = "terraform.${lower(var.environment)}.200compute.tfstate"
      region  = "${data.terraform_remote_state.main_state.outputs.state_bucket_region}"
      encrypt = "true"
    }
  }
EOF
}

###############################################################################
# Summary Output
# terraform output summary
###############################################################################
output "summary" {
  value = <<EOF

## Outputs - 200compute layer

|  | Key Pairs |
|---|---|
| key_pair_internal | ${aws_key_pair.internal.key_name} |
| key_pair_external | ${aws_key_pair.external.key_name} |
| key_pair_external_bastion | ${aws_key_pair.external_bastion.key_name} |

| Instance Name | Instance ID | Private IP | EIP | 
|---|---|---|---|
| Bastion | ${module.bastion.ar_instance_id_list[0]} | ${module.bastion.ar_instance_ip_list[0]} | ${aws_eip.bastion.public_ip} | 

| ALB Name | Endpoint |
|---|---|
| ALB | ${module.web_alb.alb_dns_name} |

EOF

  description = "200compute Layer Outputs Summary `terraform output summary` "
}
###############################################################################
# EC2 
###############################################################################
output "bastion" {
  value       = module.bastion
  description = "bastion EC2 Instance"
}

###############################################################################
# ALB 
###############################################################################
output "web_alb" {
  value       = module.web_alb
  description = "ALB"
}

###############################################################################
# ASG 
###############################################################################
output "web_asg" {
  value       = module.web_asg
  description = "ASG"
}

