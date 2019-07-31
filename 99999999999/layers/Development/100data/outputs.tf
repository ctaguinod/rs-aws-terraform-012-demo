###############################################################################
# State Import Example
# terraform output state_import_example
###############################################################################
output "state_import_example" {
  description = "An example to use this layers state in another."

  value = <<EOF

  data "terraform_remote_state" "data" {
    backend = "s3"

    config = {
      bucket  = "${data.terraform_remote_state.main_state.outputs.state_bucket_id}"
      key     = "terraform.${lower(var.environment)}.100data.tfstate"
      region  = "${data.terraform_remote_state.main_state.outputs.state_bucket_region}"
      encrypt = "true"
    }
  }
EOF
}

###############################################################################
# Summary Output
# terraform output summary
###############################################################################
output "summary" {
  value = <<EOF

## Outputs - 100data layer

| rds_master |  |
|---|---|
| Endpoint | ${module.rds_master.db_endpoint_address}|
| Internal DNS | ${aws_route53_record.rds_master.fqdn} |
| User Name | dbadmin |
| Password | ${random_string.rds_master_password.result} |

| rds_read_replica |  |
|---|---|
| Endpoint | ${module.rds_read_replica.db_endpoint_address}|
| Internal DNS | ${aws_route53_record.rds_read_replica.fqdn} |

| memcached |  |
|---|---|
| Endpoint | ${module.elasticache_memcached.elasticache_endpoint}|
| Internal DNS | ${aws_route53_record.elasticache_memcached.fqdn} |

| redis |  |
|---|---|
| Endpoint | ${module.elasticache_redis.elasticache_endpoint}|
| Internal DNS | ${aws_route53_record.elasticache_redis.fqdn} |


EOF

  description = "100data Layer Outputs Summary `terraform output summary` "
}

###############################################################################
# RDS 
###############################################################################
output rds_master {
  value       = module.rds_master
  description = "RDS MySQL Master Output"
}

output rds_read_replica {
  value       = module.rds_read_replica
  description = "RDS MySQL Read Replica Output"
}

output sg_rds_id {
  value       = aws_security_group.rds.id
  description = "RDS SG ID"
}

###############################################################################
# Elasticache 
###############################################################################
output "elasticache_memcached" {
  value = module.elasticache_memcached
}

output "elasticache_redis" {
  value = module.elasticache_redis
}

output sg_memcached_id {
  value       = aws_security_group.memcached.id
  description = "MemCached SG ID"
}

output sg_redis_id {
  value       = aws_security_group.redis.id
  description = "Redis SG ID"
}
