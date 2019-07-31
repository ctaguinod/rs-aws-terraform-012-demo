
###############################################################################
#########################       200compute Layer      #########################
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
    key     = "terraform.development.200compute.tfstate"
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

# Remote State Locals
locals {
  state_bucket_id = data.terraform_remote_state.main_state.outputs.state_bucket_id
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

# 100data 
# Get sample config from 100data layer `terraform output state_import_example`
# A name must start with a letter and may contain only letters, digits, underscores, and dashes.
data "terraform_remote_state" "data" {
  backend = "s3"

  config = {
    bucket  = "626499166183-build-state-bucket"
    key     = "terraform.development.100data.tfstate"
    region  = "ap-southeast-1"
    encrypt = "true"
  }
}

# Remote State Locals
locals {
  sg_rds_id       = data.terraform_remote_state.data.outputs.sg_rds_id
  sg_memcached_id = data.terraform_remote_state.data.outputs.sg_memcached_id
  sg_redis_id     = data.terraform_remote_state.data.outputs.sg_redis_id
}

###############################################################################
# Key Pairs
###############################################################################

resource "aws_key_pair" "internal" {
  key_name = "${var.aws_account_id}-${var.region}-${var.environment}-internal"
  public_key = file(
    "../../../scripts/${var.aws_account_id}-${var.region}-${var.environment}-internal.pem.pub",
  )
}

resource "aws_key_pair" "external" {
  key_name = "${var.aws_account_id}-${var.region}-${var.environment}-external"
  public_key = file(
    "../../../scripts/${var.aws_account_id}-${var.region}-${var.environment}-external.pem.pub",
  )
}

resource "aws_key_pair" "external_bastion" {
  key_name = "${var.aws_account_id}-${var.region}-${var.environment}-external-bastion"
  public_key = file(
    "../../../scripts/${var.aws_account_id}-${var.region}-${var.environment}-external-bastion.pem.pub",
  )
}

locals {
  key_pair_internal         = aws_key_pair.internal.key_name
  key_pair_external         = aws_key_pair.external.key_name
  key_pair_external_bastion = aws_key_pair.external_bastion.key_name
}

###############################################################################
# Bastion
# EC2 Auto Recovery Instances
# https://github.com/rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery
###############################################################################
# ALB Security Group
resource "aws_security_group" "bastion" {
  name_prefix = "PublicEc2BastionSg-"
  description = "Traffic to Bastion"
  vpc_id      = local.vpc_id

  tags = "${merge(
    local.tags,
    map("Name", "PublicEc2BastionSg")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Security Group Egress Rule
resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# Bastion Security Group Ingress Rules
resource "aws_security_group_rule" "bastion_ingress_tcp_22_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "Ingress from 0.0.0.0/0 (TCP:22)"
}

module "bastion" {
  source                  = "github.com/rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery//?ref=tf_0.12-upgrade"
  resource_name           = "bastion-tf-012-demo"
  instance_type           = "t3.micro"
  ec2_os                  = "amazon"
  primary_ebs_volume_size = "40"
  subnets                 = [local.PublicAZ1]
  security_group_list     = [aws_security_group.bastion.id]
  key_pair                = local.key_pair_external
  notification_topic      = local.notification_topic
  disable_api_termination = 0
  backup_tag_value        = "True"
  #image_id                = "ami_image_here"
}

# bastion EIP
resource "aws_eip" "bastion" {
  vpc      = true
  instance = module.bastion.ar_instance_id_list[0]

  tags = {
    Name            = "${var.environment}-bastionEIP"
    Environment     = var.environment
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }
}

output "bastion_eip" {
  value       = aws_eip.bastion.public_ip
  description = "bastion EIP"
}

resource "aws_route53_record" "bastion" {
  zone_id = local.internal_hosted_zone_id
  name    = "bastion-tf-012-demo.ec2"
  type    = "A"
  ttl     = "300"
  records = [module.bastion.ar_instance_ip_list[0]]
}

###############################################################################
# ALB
# https://github.com/rackspace-infrastructure-automation/aws-terraform-alb
###############################################################################
# SSL Certificate
locals {
  acm_certificate_arn = "arn:aws:acm:ap-southeast-1:626499166183:certificate/62b14545-0608-4b1f-b0c4-81b4452dde3e"
}

# ALB Security Group
resource "aws_security_group" "web_alb" {
  name_prefix = "PublicWebAlbSg-"
  description = "Public Web Traffic"
  vpc_id      = local.vpc_id

  tags = "${merge(
    local.tags,
    map("Name", "PublicWebAlbSg")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group Egress Rule
resource "aws_security_group_rule" "web_alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb.id
}

# ALB Security Group Ingress Rules
resource "aws_security_group_rule" "web_alb_ingress_tcp_80_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb.id
  description       = "Ingress from 0.0.0.0/0 (TCP:80)"
}

# ALB Security Group Ingress Rules
resource "aws_security_group_rule" "web_alb_ingress_tcp_443_all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb.id
  description       = "Ingress from 0.0.0.0/0 (TCP:443)"
}

module "web_alb" {
  source          = "github.com/rackspace-infrastructure-automation/aws-terraform-alb//?ref=tf_0.12-upgrade"
  alb_name        = "alb-tf-012-demo"
  security_groups = [aws_security_group.web_alb.id]
  subnets         = local.public_subnets
  vpc_id          = local.vpc_id

  http_listeners_count = 1

  http_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    },
  ]

  https_listeners_count = 1

  https_listeners = [
    {
      port            = 443
      certificate_arn = local.acm_certificate_arn
    },
  ]

  target_groups_count = 1

  target_groups = [
    {
      "name"                             = "alb-tg"
      "backend_protocol"                 = "HTTP"
      "backend_port"                     = 80
      "stickiness_enabled"               = "true"
      "cookie_duration"                  = "86400"
      "deregistration_delay"             = "30"
      "health_check_path"                = "/"
      "health_check_port"                = "traffic-port"
      "health_check_healthy_threshold"   = "5"
      "health_check_unhealthy_threshold" = "2"
      "health_check_timeout"             = "5"
      "health_check_interval"            = "30"
      "health_check_matcher"             = "200-404"
    },
  ]

  alb_tags = {
    Name            = "alb"
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }
}

# ALB Locals
locals {
  alb_dns_name      = module.web_alb.alb_dns_name
  target_group_arns = module.web_alb.target_group_arns
}

###############################################################################
# ASG
# https://github.com/rackspace-infrastructure-automation/aws-terraform-ec2_asg
###############################################################################
# ASG Security Group
resource "aws_security_group" "web_asg" {
  name_prefix = "PrivateWebAsgSg-"
  description = "Access to Web ASG insance(s)"
  vpc_id      = local.vpc_id

  tags = "${merge(
    local.tags,
    map("Name", "PrivateWebAsgSg")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# ASG Security Group Egress Rule
resource "aws_security_group_rule" "web_asg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_asg.id
}

# ASG Security Group Ingress Rules
resource "aws_security_group_rule" "web_asg_ingress_tcp_80" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.web_asg.id
  source_security_group_id = aws_security_group.web_alb.id
  description              = "Ingress from PublicWebAlbSg (TCP:80)"
}

resource "aws_security_group_rule" "web_asg_ingress_tcp_22" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  #cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.web_asg.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from PublicEc2BastionSg (TCP:22)"
}

# Allow access to RDS
resource "aws_security_group_rule" "rds_ingress_tcp_3306_from_web_asg" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.sg_rds_id
  source_security_group_id = aws_security_group.web_asg.id
  description              = "Ingress from PrivateWebAsgSg (TCP:3306)"
}

# Allow access to Elasticache Memcached
resource "aws_security_group_rule" "memcached_ingress_tcp_11211_from_web_asg" {
  type                     = "ingress"
  from_port                = 11211
  to_port                  = 11211
  protocol                 = "tcp"
  security_group_id        = local.sg_memcached_id
  source_security_group_id = aws_security_group.web_asg.id
  description              = "Ingress from PrivateWebAsgSg (TCP:11211)"
}

# Allow access to Elasticache Redis
resource "aws_security_group_rule" "redis_ingress_tcp_6379_from_web_asg" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = local.sg_redis_id
  source_security_group_id = aws_security_group.web_asg.id
  description              = "Ingress from PrivateWebAsgSg (TCP:6379)"
}

# Locals
locals {
  additional_tags = [
    {
      key                 = "MyTag1"
      value               = "Myvalue1"
      propagate_at_launch = true
    },
    {
      key                 = "MyTag2"
      value               = "Myvalue2"
      propagate_at_launch = true
    },
  ]
}

module "web_asg" {
  source                    = "github.com/rackspace-infrastructure-automation/aws-terraform-ec2_asg//?ref=tf_0.12-upgrade"
  resource_name             = "${var.env}-web-asg"
  instance_type             = "t3.micro"
  ec2_os                    = "amazon"
  primary_ebs_volume_size   = "50"
  scaling_min               = "1"
  scaling_max               = "1"
  security_group_list       = [aws_security_group.web_asg.id]
  environment               = var.environment
  subnets                   = local.private_subnets
  key_pair                  = local.key_pair_internal
  target_group_arns         = module.web_alb.target_group_arns
  cw_scaling_metric         = "CPUUtilization"
  ec2_scale_down_adjustment = "1"
  ec2_scale_down_cool_down  = "60"
  ec2_scale_up_adjustment   = "1"
  cw_high_threshold         = "60"
  cw_low_threshold          = "30"
  ec2_scale_up_cool_down    = "60"
  health_check_grace_period = "300"
  cw_low_evaluations        = "3"
  cw_high_evaluations       = "3"
  cw_high_operator          = "GreaterThanThreshold"
  additional_tags           = local.additional_tags[*]
  #image_id                  = "ami_image_here"
  #ssm_patching_group        = "PatchGroupHere"
  #backup_tag_value          = "True"
  #final_userdata_commands   = data.template_file.final_userdata_commands.rendered
}

#data "template_file" "final_userdata_commands" {
#  template = "${file("../../../scripts/install_apache.sh")}"
#}