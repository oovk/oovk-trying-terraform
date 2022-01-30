# oovk-trying-terraform
Trying IAAS Terraform Application

## Terraform commands: 
- terraform init(initialize)
- terraform apply(apply given config)
- terraform plan(shows resource plan)
- terraform destroy(removes all the deployed resources)

## Symbols: 
- \+ -> (added changes)
- \- -> (removed changes)
- ~ -> (updations in infra)


# Tasks Performed on AWS:
1. Create vpc
2. Create Internet Gateway
3. Create custom route table
4. Create subnet
5. Associate subnet with route table
6. Create security group to allow port 22, 80, 443
7. Create network interface with an ip in the subnet that was created in step 4
8. Assign an elastic IP to the network interface created in step 7
9. Create Ubuntu server and install/enable apache

Ref.link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
