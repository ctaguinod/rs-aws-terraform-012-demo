# Initialisation

This layer is used to create a S3 bucket for remote state storage.

### Create

Update the `terraform.tfvars` file to include your required environment and region. This is just for the state bucket and not for where you are deploying your code so you can choose to place the bucket in a location closer to you than the target for the build.

- generate AWS temporary credentials (see FAWS Janus)
- update terraform.tfvars with your environent and region

```bash
$ terraform init
$ terraform apply
```

### Destroy

* generate AWS temporary credentials (see FAWS Janus)

```bash
$ terraform destroy
```

When prompted, check the plan and then respond in the affirmative.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| amg\_header | Account Management Guideline Header | string | `"Customer is being managed manually via the AWS Console. Do not make changes to existing resources via CloudFormation."` | no |
| aws\_account\_id | AWS Account ID | string | n/a | yes |
| change\_management | Change Management | string | `"SysOps (manual changes)"` | no |
| env | Short environment variable, e.g. Dev, Prod, Test | string | `"Dev"` | no |
| environment | Name of the environment for the deployment, e.g. Integration, PreProduction, Production, QA, Staging, Test | string | `"Development"` | no |
| github | Github URL | string | n/a | yes |
| janus | Janus URL | string | n/a | yes |
| region | Default Region | string | `"ap-southeast-1"` | no |
| service\_level | Service Level (e.g. Aviator) | string | `"Aviator"` | no |
| status | Status | string | `"(In Build)"` | no |
| wiki | One Wiki URL | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| amg | Account Management Guidelines |
| s3\_terraform\_bucket\_id | S3 bucket id for Terraform state files |
| s3\_terraform\_bucket\_region | S3 bucket region |
| terraform\_remote\_state\_configuration\_example | Terraform block to put into the build layers |