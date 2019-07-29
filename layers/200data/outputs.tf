###############################################################################
# Outputs
# terraform output summary
###############################################################################

output "summary" {
  value = <<EOF

## Outputs - 200data layer

| rds-master |  |
|---|---|
| Endpoint | ${module.rds-master.db_endpoint_address}|
| Internal DNS | ${aws_route53_record.rds-master.fqdn} |
| User Name | dbadmin |
| Password | ${random_string.rds-master-password.result} |

| rds-read-replica |  |
|---|---|
| Endpoint | ${module.rds-read-replica.db_endpoint_address}|
| Internal DNS | ${aws_route53_record.rds-read-replica.fqdn} |

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
