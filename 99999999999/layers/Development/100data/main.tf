
###############################################################################
#########################       100data Layer         #########################
###############################################################################

###############################################################################
# Providers
###############################################################################
provider "aws" {
  version             = "~> 2.0"
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

locals {
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }
}

###############################################################################
# Terraform main config
# terraform block cannot be interpolated; sample provided as output of _main
# `terraform output remote_state_configuration_example`
###############################################################################
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    # Get S3 Bucket name from layer _main (`terraform output state_bucket_id`)
    bucket = "626499166183-build-state-bucket"
    # This key must be unique for each layer!
    key     = "terraform.development.100data.tfstate"
    region  = "ap-southeast-1"
    encrypt = "true"
  }
}

###############################################################################
# Terraform Remote State 
###############################################################################
# _main
data "terraform_remote_state" "main_state" {
  backend = "local"

  config = {
    path = "../../_main/terraform.tfstate"
  }
}

# 000base 
# Get sample config from 000base layer `terraform output state_import_example`
# A name must start with a letter and may contain only letters, digits, underscores, and dashes.
data "terraform_remote_state" "base_network" {
  backend = "s3"

  config = {
    bucket  = "626499166183-build-state-bucket"
    key     = "terraform.development.000base.tfstate"
    region  = "ap-southeast-1"
    encrypt = "true"
  }
}

# Remote State Locals
locals {
  state_bucket_id         = data.terraform_remote_state.main_state.outputs.state_bucket_id
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
# RDS - MySQL Master
# https://github.com/rackspace-infrastructure-automation/aws-terraform-rds
###############################################################################

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "PrivateRdsSg-"
  description = "Access to RDS"
  vpc_id      = local.vpc_id

  tags = "${merge(
    local.tags,
    map("Name", "PrivateRdsSg")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Security Group Egress Rule
resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}

# Generate Random Password
resource "random_string" "rds_master_password" {
  length  = 20
  lower   = true
  upper   = true
  number  = true
  special = false
}

# Store Random Password in SSM parameter
resource "aws_ssm_parameter" "rds_master_password" {
  name  = "${lower(var.environment)}-rds-master-password"
  type  = "SecureString"
  value = "${random_string.rds_master_password.result}"

  lifecycle {
    ignore_changes = all
  }
}

module "rds_master" {
  source              = "github.com/rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"
  subnets             = local.private_subnets
  security_groups     = [aws_security_group.rds.id]
  name                = "rds-master"
  engine              = "mysql"
  engine_version      = "5.6.37" # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  instance_class      = "db.t3.micro"
  storage_size        = "20"
  username            = "dbadmin"
  password            = random_string.rds_master_password.result
  environment         = var.environment
  tags                = local.tags
  create_subnet_group = true
  create_option_group = true
  storage_encrypted   = true
}

resource "aws_route53_record" "rds_master" {
  zone_id = local.internal_hosted_zone_id
  name    = "rds-master.rds"
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds_master.db_endpoint_address]
}

###############################################################################
# RDS - MySQL Read Replica
# https://github.com/rackspace-infrastructure-automation/aws-terraform-rds
###############################################################################

module "rds_read_replica" {
  source              = "github.com/rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"
  subnets             = local.private_subnets
  security_groups     = [aws_security_group.rds.id]
  name                = "rds-read-replica"
  engine              = "mysql"
  engine_version      = "5.6.37" # Should be same version as master
  instance_class      = "db.t3.micro"
  storage_size        = "20"                          # Same size from master 
  username            = "dbadmin"                     # Same User from master
  password            = ""                            # Retrieved from source DB
  read_replica        = true                          # Required
  source_db           = module.rds_master.db_instance # Master RDS ARN / module.rds_master.db_instance_arn
  environment         = var.environment
  tags                = local.tags
  create_subnet_group = false
  create_option_group = false
  storage_encrypted   = true
}

resource "aws_route53_record" "rds_read_replica" {
  zone_id = local.internal_hosted_zone_id
  name    = "rds-read-replica.rds"
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds_read_replica.db_endpoint_address]
}

###############################################################################
# Elasticache - MemCached
# https://github.com/rackspace-infrastructure-automation/aws-terraform-elasticache
##############################################################################

# MemCached Security Group
resource "aws_security_group" "memcached" {
  name_prefix = "PrivateMemCachedSg-"
  description = "Access to MemCached"
  vpc_id      = local.vpc_id

  tags = "${merge(
    local.tags,
    map("Name", "PrivateMemCachedSg")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# MemCached Security Group Egress Rule
resource "aws_security_group_rule" "memcached_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.memcached.id
}

module "elasticache_memcached" {
  source                     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=tf_0.12-upgrade"
  cluster_name               = "memcached"
  elasticache_engine_type    = "memcached14"
  instance_class             = "cache.t2.micro"
  subnets                    = local.private_subnets
  internal_record_name       = "memcached"
  security_group_list        = [aws_security_group.memcached.id]
  create_route53_record      = true
  internal_zone_id           = local.internal_hosted_zone_id
  internal_zone_name         = local.internal_hosted_zone_id
  environment                = var.environment
  curr_connections_threshold = 500
  evictions_threshold        = 10

  /*
  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
  */
}

resource "aws_route53_record" "elasticache_memcached" {
  zone_id = local.internal_hosted_zone_id
  name    = "memcached"
  type    = "CNAME"
  ttl     = "300"
  records = [module.elasticache_memcached.elasticache_endpoint]
}

###############################################################################
# Elasticache - Redis
# https://github.com/rackspace-infrastructure-automation/aws-terraform-elasticache
##############################################################################
# Redis Security Group
resource "aws_security_group" "redis" {
  name_prefix = "PrivateRedisSg-"
  description = "Access to Redis"
  vpc_id      = local.vpc_id

  tags = "${merge(
    local.tags,
    map("Name", "PrivateRedisSg")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# Redis Security Group Egress Rule
resource "aws_security_group_rule" "redis_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis.id
}

module "elasticache_redis" {
  source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=tf_0.12-upgrade"
  cluster_name            = "redis"
  elasticache_engine_type = "redis50"
  instance_class          = "cache.t2.micro"
  redis_multi_shard       = false
  subnets                 = local.private_subnets
  security_group_list     = [aws_security_group.redis.id]
  internal_record_name    = "redis"
  create_route53_record   = true
  internal_zone_id        = local.internal_hosted_zone_id
  internal_zone_name      = local.internal_hosted_zone_id
  environment             = var.environment

  /*
  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
  */
}

resource "aws_route53_record" "elasticache_redis" {
  zone_id = local.internal_hosted_zone_id
  name    = "redis"
  type    = "CNAME"
  ttl     = "300"
  records = [module.elasticache_redis.elasticache_endpoint]
}
