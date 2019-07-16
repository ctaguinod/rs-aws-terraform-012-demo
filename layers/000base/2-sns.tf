###############################################################################
# SNS
###############################################################################
module "sns_topic" {
  source     = "github.com/rackspace-infrastructure-automation/aws-terraform-sns//?ref=tf_0.12-upgrade"
  topic_name = "${var.environment}-sns-topic"
}

output "sns_topic" {
  description = "SNS Topic"
  value       = module.sns_topic
}