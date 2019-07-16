###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "AWS Account ID"
}

variable "region" {
  description = "Default Region"
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Name of the environment for the deployment, e.g. Integration, PreProduction, Production, QA, Staging, Test"
  default     = "Development"
}

variable "env" {
  description = "Short environment variable, e.g. Dev, Prod, Test"
  default     = "Dev"
}

###############################################################################
# Variables - Route53 Zone
###############################################################################
variable "zone_id" {
  description = "(Required) The ID of the hosted zone to contain this record."
  default     = ""
}

variable "name" {
  description = "(Required) The name of the record."
  default     = ""
}

variable "type" {
  description = "(Required) The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT."
  default     = "A"
}

variable "ttl" {
  description = "(Required for non-alias records) The TTL of the record."
  default     = "300"
}

variable "records" {
  description = "(Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add \"\" inside the Terraform configuration string."
  default     = ""
}

