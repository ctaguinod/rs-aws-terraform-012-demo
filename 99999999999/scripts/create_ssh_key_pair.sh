#!/bin/bash
aws_account_id="999999999999" 
region="ap-southeast-1"
env="Development" # Production, Development, Staging
label_internal="internal"
label_external="external"
label_bastion="external-bastion"

# Create Key for Internal Servers
ssh-keygen -m PEM -t rsa -b 4096 -C "$aws_account_id-$region-$env-$label" -f "$aws_account_id-$region-$env-$label_internal".pem

# Create Key for External Servers
ssh-keygen -m PEM -t rsa -b 4096 -C "$aws_account_id-$region-$env-$label_external" -f "$aws_account_id-$region-$env-$label_external".pem

# Create Key for Bastion Servers
ssh-keygen -m PEM -t rsa -b 4096 -C "$aws_account_id-$region-$env-$label_external" -f "$aws_account_id-$region-$env-$label_bastion".pem

ls -l *.pem *.pem.pub

echo "Make sure to upload the keys to PasswordSafe - Category: <DDI>-<CustomerName>"
echo "PasswordSafe Standards: https://one.rackspace.com/display/maws/PasswordSafe+conventions+and+standards"
