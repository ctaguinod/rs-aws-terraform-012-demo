###############################################################################
# Outputs
# terraform output terraform_remote_state_configuration_example
###############################################################################
output "terraform_remote_state_configuration_example" {
  value = <<EOF
  terraform {
    backend "s3" {
      # this key must be unique for each layer!
      key            = "000base/terraform.tfstate"
      bucket         = "${module.s3_terraform.bucket_id}"
      region         = "${module.s3_terraform.bucket_region}"
      dynamodb_table = "terraform-state"
      encrypt        = "true"
    }
  }
EOF

  description = "Terraform block to put into the build layers"
}

output "s3_terraform" {
  value = module.s3_terraform
  description = "module s3_terraform output"
}

###############################################################################
# AMG (Account Management Guidelines)
# terraform output amg
###############################################################################

output "amg" {
  value = <<EOF
### AMG
***${var.amg_header}***  <br/>
AWS Account: ***${var.aws_account_id}***  <br/>
Janus: ${var.janus}  <br/>
Wiki: ${var.wiki}  <br/>
Region(s): ${var.region}  <br/>
Github: ${var.github}  <br/>
Service Level:  ${var.service_level}  <br/>
Change Management: ${var.change_management}  <br/>
Status: ${var.status}  <br/>
EOF


description = "Account Management Guidelines"
}

