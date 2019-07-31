###############################################################################
# Outputs
# terraform output remote_state_configuration_example
# key must be unique for each layer!
###############################################################################
output "remote_state_configuration_example" {
  value = <<EOF

  terraform {
    backend "s3" {
      # this key must be unique for each layer!
      bucket  = "${aws_s3_bucket.state.id}"
      key     = "terraform.EXAMPLE.000base.tfstate"
      region  = "${aws_s3_bucket.state.region}"
      encrypt = "true"
    }
  }
EOF

  description = "A suggested terraform block to put into the build layers. `terraform output remote_state_configuration_example`"
}

output "state_bucket_id" {
  value = "${aws_s3_bucket.state.id}"
  description = "The ID of the bucket to be used for state files."
}

output "state_bucket_region" {
  value = "${aws_s3_bucket.state.region}"
  description = "The region the state bucket resides in."
}

###############################################################################
# Outputs
# terraform output state_import_example
###############################################################################
output "state_import_example" {
  value = <<EOF

  data "terraform_remote_state" "main_state" {
    backend = "local"

    config = {
      path = "../../_main/terraform.tfstate"
    }
  }
EOF

  description = "An example to use this layers state in another. `terraform output state_import_example`"
}

###############################################################################
# Outputs: AMG (Account Management Guidelines)
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

  description = "Account Management Guidelines `terraform output amg`"
}
