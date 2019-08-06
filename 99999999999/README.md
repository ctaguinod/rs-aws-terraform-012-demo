# Terraform 0.12 Demo

Clone the repo.
```
git clone git@github.com:ctaguinod/rs-aws-terraform-012-demo.git
cd rs-aws-terraform-012-demo
```

## Provision ***_main*** layer
- This layer will provision s3 bucket for terraform state.

1. Create terraform.tfvars from sample file and fill in with correct parameters
```
cd 99999999999//layers/_main/
cp terraform.tfvars-example terraform.tfvars
```

2. Initialise and apply
```
terraform init
terraform apply
```

3. Run `terraform output state_import_example` to display sample remote state import config.

4. Run `terraform output remote_state_configuration_example` to display sample remote state config.


## Provision ***000base*** layer
- This layer will provision the base infrastructure such as **VPC**, **route53** internal hosted zone and **sns** topic.

1. Create `terraform.tfvars` from sample file and fill in with correct parameters
```
cd ../Development/000base/
cp terraform.tfvars-example terraform.tfvars
```

2. Modify `main.tf` and update correct parameters as needed. Make sure to update the `# Terraform main config` section for the correct s3 `bucket` and `key` for the Terraform state.

3. Initialise and apply
```
terraform init
terraform apply
```

4. Run `terraform output state_import_example` to display sample remote state import config.

5. Run `terraform output summary` to display resources outputs.


## Provision ***100data*** layer
- This layer will provision the data layer such as **RDS MySQL**, **RDS MySQL Read Replica**, **Elasticache Memcached**, **Elasticache Redis** .

1. Create `terraform.tfvars` from sample file and fill in with correct parameters
```
cd ../100data/
cp terraform.tfvars-example terraform.tfvars
```

2. Modify `main.tf` and update correct parameters as needed. Make sure to update the `# Terraform main config` section for the correct s3 `bucket` and `key` for the Terraform state and the `# Terraform Remote State` section for the Remote states.

3. Initialise and apply
```
terraform init
terraform apply
```

4. Run `terraform output state_import_example` to display sample remote state import config.

5. Run `terraform output summary` to display resources outputs.


## Provision ***200compute*** layer
- This layer will provision the compute resources such as **Key Pairs**, **Security Groups**, **ALB**, **ASG**, **EC2 Bastion instance**.

1. Create `terraform.tfvars` from sample file and fill in with correct parameters
```
cd ../200compute/
cp terraform.tfvars-example terraform.tfvars
```

2. Modify `main.tf` and update correct parameters as needed. Make sure to update the `# Terraform main config` section for the correct s3 `bucket` and `key` for the Terraform state and the `# Terraform Remote State` section for the Remote states.

3. Generate SSH Keys
- Modify `create_ssh_key_pair.sh` and update with correct parameters, make sure to chance the `aws_account_id`, `region` and `env` parameters.
```
cd ../../../scripts/
bash create_ssh_key_pair.sh
```

4. Initialise and apply
```
cd ../layers/Development/200compute/
terraform init
terraform apply
```

5. Run `terraform output state_import_example` to display sample remote state import config.

6. Run `terraform output summary` to display resources outputs.
