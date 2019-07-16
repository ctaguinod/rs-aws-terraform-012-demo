## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | AWS Account ID | string | n/a | yes |
| az\_count | Number of AZs to utilize for the subnets | string | n/a | yes |
| build\_nat\_gateways | Whether or not to build a NAT gateway per AZ. if build_igw is set to false, this value is ignored. | string | n/a | yes |
| cidr\_range | CIDR range for the VPC | string | n/a | yes |
| custom\_azs | A list of AZs that VPC resources will reside in | list | n/a | yes |
| env | Short environment variable, e.g. Dev, Prod, Test | string | `"Dev"` | no |
| environment | Name of the environment for the deployment, e.g. Integration, PreProduction, Production, QA, Staging, Test | string | `"Development"` | no |
| private\_cidr\_ranges | An array of CIDR ranges to use for private subnets | list | n/a | yes |
| private\_subnets\_per\_az | Number of private subnets to create in each AZ. NOTE: This value, when multiplied by the value of az_count, should not exceed the length of the private_cidr_ranges list! | string | n/a | yes |
| public\_cidr\_ranges | An array of CIDR ranges to use for public subnets | list | n/a | yes |
| public\_subnets\_per\_az | Number of public subnets to create in each AZ. NOTE: This value, when multiplied by the value of az_count, should not exceed the length of the public_cidr_ranges list! | string | n/a | yes |
| region | Default Region | string | `"ap-southeast-1"` | no |
| vpc\_name | Name for the VPC | string | `"BaseNetwork"` | no |

## Outputs

| Name | Description |
|------|-------------|
| NatPrivateIPAZ1 | The NAT gateway private IP in Public AZ1 |
| NatPrivateIPAZ2 | The NAT gateway private IP in Public AZ2 |
| NatPublicIPAZ1 | The NAT gateway Public IP in Public AZ1 |
| NatPublicIPAZ2 | The NAT gateway Public IP in Public AZ2 |
| base\_network | Base Network Outputs |
| internal\_zone | Route53 Internal Hosted Zone |
| sns\_topic | SNS Topic |
| summary | Base Network Layer Outputs Summary `terraform output summary` |
| terraform\_remote\_state\_configuration\_example | Terraform block to put into the build layers |
| terraform\_remote\_state\_import\_example | Example how to use remote state from other layers |