# Terraform 0.12 Demo

Clone the repo.
```
git clone git@github.com:ctaguinod/rs-aws-terraform-012-demo.git
```

## Provision ***_main*** layer
- This layer will provision s3 bucket for terraform state and dynamodb table for locking.

1. Create terraform.tfvars from sample file and fill in with correct parameters
```
cd rs-aws-terraform-012-demo/layers/_main/
cp terraform.tfvars-example terraform.tfvars
```

2. Initialise and apply
```
terraform init
terraform apply
```

## Provision ***000base*** layer
- This layer will provision the base infrastructure such as VPC, route53 internal hosted zone and sns topic.

1. Create `terraform.tfvars` from sample file and fill in with correct parameters
```
cd ../000base/
cd rs-aws-terraform-012-demo/layers/_main/
cp terraform.tfvars-example terraform.tfvars
```
2. Modify `main.tf` and update correct parameters for the remote state under the terraform block.

3. Modify `remote_states.tf` and update correct parameters for the remote state data.

4. Modify TF files as needed `0-base_network.tf`, `1-route53_internal_zone.tf`, `2-sns.tf`

5. Initialise and apply
```
terraform init
terraform apply
```

## Provision ***100compute*** layer
- This layer will provision the compute resources such as Key Pairs, Security Groups, ALB, ASG, EC2 Bastion instance.

1. Create `terraform.tfvars` from sample file and fill in with correct parameters
```
cd ../100compute/
cd rs-aws-terraform-012-demo/layers/_main/
cp terraform.tfvars-example terraform.tfvars
```

2. Modify `main.tf` and update correct parameters for the remote state under the terraform block.

3. Modify `remote_states.tf` and update correct parameters for the remote state data.

4. Modify TF files as needed `1-key_pair.tf` , `2-security_groups.tf`, `3-alb.tf`, `4-asg.tf`, `5-ec2.tf`

5. Generate SSH Keys
- Modify `create_ssh_key_pair.sh` and update with correct parameters
```
cd ../../scripts/
bash create_ssh_key_pair.sh
```

6. Initialise and apply
```
cd ../layers/100compute/
terraform init
terraform apply
```