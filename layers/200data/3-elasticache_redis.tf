###############################################################################
# Security Group for ElasticCache Redis Server
###############################################################################

resource "aws_security_group" "ElasticCacheRedisSecurityGroup" {
  name_prefix = "ElasticCacheRedisSecurityGroup-"
  description = "ElastiCache Redis Security Group"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
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
    Name            = "${var.environment}-ElasticCacheRedisSecurityGroup"
    ServiceProvider = "Rackspace"
    Terraform       = "True"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Elasticache - Redis
# https://github.com/rackspace-infrastructure-automation/aws-terraform-elasticache
##############################################################################

module "elasticache_redis" {
  source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=tf_0.12-upgrade"
  cluster_name            = "redis"
  elasticache_engine_type = "redis50"
  instance_class          = "cache.t2.micro"
  redis_multi_shard       = false
  subnets                 = local.private_subnets
  security_group_list     = [aws_security_group.ElasticCacheRedisSecurityGroup.id]
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

output "elasticache_redis" {
  value = module.elasticache_redis
}
