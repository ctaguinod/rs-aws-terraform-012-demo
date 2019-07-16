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

output "s3_terraform_bucket" {
  value       = data.terraform_remote_state.main_state.outputs.s3_terraform.bucket_id
  description = "terraform s3 bucket for remote state"
}