###############################################################################
# Security Groups
# https://github.com/rackspace-infrastructure-automation/aws-terraform-security_group
###############################################################################

### For ALB
resource "aws_security_group" "PublicWebSecurityGroup" {
  name_prefix = "PublicWebSecurityGroup-"
  description = "Public Web Traffic"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment     = var.environment
    Name            = "${var.environment}-PublicWebSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "PublicWebSecurityGroup" {
  value       = aws_security_group.PublicWebSecurityGroup.id
  description = "Public Web Security Group"
}

### For Web Server
resource "aws_security_group" "PrivateWebSecurityGroup" {
  name_prefix = "PrivateWebSecurityGroup-"
  description = "Allowsed traffic to Web Servers"
  vpc_id      = local.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.PublicWebSecurityGroup.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.PublicWebSecurityGroup.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment     = var.environment
    Name            = "${var.environment}-PrivateWebSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "PrivateWebSecurityGroup" {
  value       = aws_security_group.PrivateWebSecurityGroup.id
  description = "Private Web Security Group"
}

### For Bastion Server
resource "aws_security_group" "BastionSecurityGroup" {
  name_prefix = "BastionSecurityGroup-"
  description = "SSH Access to Bastion"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["180.150.145.101/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment     = var.environment
    Name            = "${var.environment}-BastionSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "BastionSecurityGroup" {
  value       = aws_security_group.BastionSecurityGroup.id
  description = "Bastion Security Group"
}

### For Web Server
resource "aws_security_group" "PrivateSSHSecurityGroup" {
  name_prefix = "PrivateSSHSecurityGroup-"
  description = "Allow SSH From Bastion"
  vpc_id      = local.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.BastionSecurityGroup.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment     = var.environment
    Name            = "${var.environment}-PrivateSSHSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "PrivateSSHSecurityGroup" {
  value       = aws_security_group.PrivateSSHSecurityGroup.id
  description = "Private SSH Security Group"
}

###############################################################################
# Locals
###############################################################################
locals {
  PublicWebSecurityGroup  = aws_security_group.PublicWebSecurityGroup.id
  PrivateWebSecurityGroup = aws_security_group.PrivateWebSecurityGroup.id
  BastionSecurityGroup    = aws_security_group.BastionSecurityGroup.id
  PrivateSSHSecurityGroup = aws_security_group.PrivateSSHSecurityGroup.id
}

