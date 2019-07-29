###############################################################################
# Security Group for ElasticCache Memcache Server
###############################################################################

resource "aws_security_group" "ElasticCacheMemcachedSecurityGroup" {
  name_prefix = "ElasticCacheMemcachedSecurityGroup-"
  description = "ElastiCache Memcached Security Group"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 11211
    to_port     = 11211
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
    Name            = "${var.environment}-ElasticCacheMemcachedSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Elasticache - MemCached
# https://github.com/rackspace-infrastructure-automation/aws-terraform-elasticache
##############################################################################

module "elasticache_memcached" {
  source                     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=tf_0.12-upgrade"
  cluster_name               = "memcached"
  elasticache_engine_type    = "memcached14"
  instance_class             = "cache.t2.micro"
  subnets                    = local.private_subnets
  internal_record_name       = "memcached"
  security_group_list        = [aws_security_group.ElasticCacheMemcachedSecurityGroup.id]
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

output "elasticache_memcached" {
  value = module.elasticache_memcached
}
