# Deploying OSM data to AWS

A collection of Terraform and Ansible scripts for provisioning an AWS EC2 instance for OpenStreetMap data.

## TO-DO
- Download and set up OSM data in EC2 instance
- Rather than destroying instance completely save snapshot/EBS volume to S3, and re-provision from this in future

## Usage

### Prerequisites

- An AWS account.
- Public and private access keys.
- A pre-existing key pair for accessing the EC2 instance.

### Set-up necessary variables

You need to specify several user variables in the `variables.tf` file, i.e. on the command-line or in a `terraform.tfvars` file. Required variables are:

- `my_ip`: Your IP address (SSH access is restricted to your IP)
- `access_key`: Your AWS public access key
- `secret_key`: Your AWS private key
- `ec2_key_pair`: The name of the key-pair that will be associated with the created EC2 for SSH access
- `ssh_key_private`: The .pem file associated with `ec2_key_pair`

### Run

Provision using:

```bash
terraform apply
```

You may have to specify user variables at this point. For example, to programmatically find your IP address at deployment, run using:

```bash
terraform apply -var "my_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)"
```

Destroy the infrastructure using `terraform destroy`

### SSH access

To SSH into the instance from the command-line, run (inserting the correct path to your key.pem file):

```bash
ssh -i /path/to/your-key.pem ubuntu@ec2-$(cat inventory | sed 's/\./-/g').compute-1.amazonaws.com
```

## License

Licensed under the MIT license.
