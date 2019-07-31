###############################################################################
# Summary Output
# terraform output summary
###############################################################################
output "summary" {
  value = <<EOF

## Outputs - 200data layer

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

  description = "200data Layer Outputs Summary `terraform output summary` "
}

###############################################################################
# RDS 
###############################################################################
output rds_master {
  value = module.rds_master
  description = "RDS MySQL Master Output"
}

output rds_read_replica {
  value = module.rds_read_replica
  description = "RDS MySQL Read Replica Output"
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
