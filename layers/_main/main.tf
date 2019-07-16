###############################################################################
# Providers
###############################################################################
provider "aws" {
  version             = "~> 2.0"
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

###############################################################################
# Terraform main config 
###############################################################################
terraform {
  required_version = ">= 0.12"
}

###############################################################################
# S3 Bucket for Terraform state
# https://github.com/rackspace-infrastructure-automation/aws-terraform-s3
###############################################################################

module "s3_terraform" {
  source                             = "github.com/rackspace-infrastructure-automation/aws-terraform-s3?ref=tf_0.12-upgrade"
  bucket_name                        = "rs-tfstate-${var.aws_account_id}-${var.region}"
  bucket_acl                         = "private"
  versioning                         = true
  environment                        = var.environment
  lifecycle_enabled                  = true
  noncurrent_version_expiration_days = "30"
}

###############################################################################
# DynamobDB Table for Terraform State Locking
###############################################################################
resource "aws_dynamodb_table" "terraform-state" {
  name           = "terraform-state"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

