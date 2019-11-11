# bespin
☁️ Infrastructure configuration for Riht

## Dependencies:
* terraform 0.12

## Set-Up Instructions

1. Follow the instructions
[here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) to create
an AWS EC2 key pair which you will need to be able to SSH into the EC2 instance(s).
2. Create a file in the root of this repo called `terraform.tfvars` and fill it out like this:
```
access_key = "YOUR_AWS_ACCESS_KEY_ID"
secret_key = "YOUR_AWS_SECRET_ACCESS_KEY"
key_name   = "YOUR_AWS_EC2_KEY_PAIR_NAME"
```
3. Run `terraform plan` to see what resources will be created and then `terraform apply` to create the resources. Enter
`yes` when prompted by Terraform.
4. Once the previous command is done running, the AWS resources should now be visible in the AWS console (UI) and ready
to be used for development/testing. Once you're done using the resources, run `terraform destroy`. Enter `yes` when
prompted by Terraform.
