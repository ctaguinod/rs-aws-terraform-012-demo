###############################################################################
# Variables
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

variable "amg_header" {
  default     = "Customer is being managed manually via the AWS Console. Do not make changes to existing resources via CloudFormation."
  description = "Account Management Guideline Header"
}

variable "janus" {
  description = "Janus URL"
}

variable "wiki" {
  description = "One Wiki URL"
}

variable "github" {
  description = "Github URL"
}

variable "service_level" {
  description = "Service Level (e.g. Aviator)"
  default     = "Aviator"
}

variable "change_management" {
  description = "Change Management"
  default     = "SysOps (manual changes)"
}

variable "status" {
  description = "Status"
  default     = "(In Build)"
}

