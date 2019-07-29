###############################################################################
# Locals
###############################################################################
locals {
  # Add additional tags in the below map
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }
}

###############################################################################
# Security Group for MySQL Server
###############################################################################

resource "aws_security_group" "MySQLSecurityGroup" {
  name_prefix = "MySQLSecurityGroup-"
  description = "Allowsed traffic to RDS MySQL Servers"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment     = var.environment
    Name            = "${var.environment}-MySQLSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output MySQLSecurityGroup {
  value       = aws_security_group.MySQLSecurityGroup
  description = "MySQL Security Group"
}

####################################
# Generate Random Password
####################################
resource "random_string" "rds-master-password" {
  length  = 20
  lower   = true
  upper   = true
  number  = true
  special = false
}

resource "aws_ssm_parameter" "rds-master-password" {
  name  = "${lower(var.environment)}-rds-master-password"
  type  = "SecureString"
  value = "${random_string.rds-master-password.result}"

  lifecycle {
    ignore_changes = all
  }
}

###############################################################################
# RDS - MySQL Master
# https://github.com/rackspace-infrastructure-automation/aws-terraform-rds
###############################################################################
module "rds-master" {
  source              = "github.com/rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"
  subnets             = local.private_subnets
  security_groups     = [aws_security_group.MySQLSecurityGroup.id]
  name                = "rds-master"
  engine              = "mysql"
  engine_version      = "5.6.37" # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  instance_class      = "db.t3.micro"
  storage_size        = "20"
  username            = "dbadmin"
  password            = random_string.rds-master-password.result
  environment         = var.environment
  tags                = local.tags
  create_subnet_group = true
  create_option_group = true
  storage_encrypted   = true
}

resource "aws_route53_record" "rds-master" {
  zone_id = local.internal_hosted_zone_id
  name    = "rds-master.rds"
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds-master.db_endpoint_address]
}

output rds-master {
  value       = module.rds-master
  description = "RDS MySQL Master Output"
}


###############################################################################
# RDS - MySQL Read Replica
# https://github.com/rackspace-infrastructure-automation/aws-terraform-rds
###############################################################################

module "rds-read-replica" {
  source              = "github.com/rackspace-infrastructure-automation/aws-terraform-rds//?ref=tf_0.12-upgrade"
  subnets             = local.private_subnets
  security_groups     = [aws_security_group.MySQLSecurityGroup.id]
  name                = "rds-read-replica"
  engine              = "mysql"
  engine_version      = "5.6.37" # Should be same version as master
  instance_class      = "db.t3.micro"
  storage_size        = "20"                          # Same size from master 
  username            = "dbadmin"                     # Same User from master
  password            = ""                            # Retrieved from source DB
  read_replica        = true                          # Required
  source_db           = module.rds-master.db_instance # Master RDS ARN / module.rds-master.db_instance_arn
  environment         = var.environment
  tags                = local.tags
  create_subnet_group = false
  create_option_group = false
  storage_encrypted   = true
}

resource "aws_route53_record" "rds-read-replica" {
  zone_id = local.internal_hosted_zone_id
  name    = "rds-read-replica.rds"
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds-read-replica.db_endpoint_address]
}

output rds-read-replica {
  value       = module.rds-read-replica
  description = "RDS MySQL Read Replica Output"
}
