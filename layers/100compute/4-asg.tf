###############################################################################
# Locals
###############################################################################
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

###############################################################################
# ASG
# https://github.com/rackspace-infrastructure-automation/aws-terraform-ec2_asg
###############################################################################

module "asg" {
  source                    = "github.com/rackspace-infrastructure-automation/aws-terraform-ec2_asg//?ref=tf_0.12-upgrade"
  resource_name             = "${var.environment}-asg"
  instance_type             = "t3.micro"
  ec2_os                    = "amazon"
  primary_ebs_volume_size   = "50"
  scaling_min               = "1"
  scaling_max               = "1"
  security_group_list       = [local.PrivateWebSecurityGroup, local.PrivateSSHSecurityGroup]
  environment               = var.environment
  subnets                   = local.private_subnets
  key_pair                  = local.key_pair_internal
  target_group_arns         = module.alb.target_group_arns
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
  #final_userdata_commands   = "${data.template_file.final_userdata_commands.rendered}"
}

#data "template_file" "final_userdata_commands" {
#  template = "${file("../scripts/install_apache.sh")}"
#}

output "asg" {
  value       = module.asg
  description = "ASG"
}