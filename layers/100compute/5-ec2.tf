###############################################################################
# EC2 Auto Recovery Instances
# https://github.com/rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery
###############################################################################
module "bastion" {
  source                  = "github.com/rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery//?ref=tf_0.12-upgrade"
  resource_name           = "bastion-tf-012-demo"
  instance_type           = "t3.micro"
  ec2_os                  = "amazon"
  primary_ebs_volume_size = "40"
  subnets                 = [local.PublicAZ1]
  security_group_list     = [local.BastionSecurityGroup]
  key_pair                = local.key_pair_external
  notification_topic      = local.notification_topic
  disable_api_termination = 0
  backup_tag_value        = "True"
  #image_id                = "ami_image_here"
}

output "bastion" {
  value       = module.bastion
  description = "bastion EC2 Instance"
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
