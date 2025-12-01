# Quick Start - Hera Infrastructure

Fast-track guide for deploying Hera infrastructure to AWS.

## Prerequisites

```bash
# Check prerequisites
aws --version                      # AWS CLI installed
terraform version                  # Terraform >= 1.6.0
aws sts get-caller-identity        # AWS credentials configured
```

## Step 1: Bootstrap (One-Time)

```bash
# Navigate to bootstrap directory
cd infra/terraform/envs/bootstrap/aws

# Edit terraform.tfvars with your AWS account ID
# region         = "us-east-1"
# aws_account_id = "YOUR_ACCOUNT_ID"

# Apply bootstrap
terraform init
terraform plan
terraform apply  # Type 'yes' when prompted
```

**What this creates:**
- S3 bucket: `hera-dev-tf-state`
- DynamoDB table: `hera-dev-tf-lock`
- IAM role: `hera-dev-admin`

**Important:** Backup the `terraform.tfstate` file in this directory!

## Step 2: Initialize Dev Environment

```bash
# Navigate to dev directory
cd ../../dev/aws

# Initialize with S3 backend
terraform init
```

**What this does:**
- Configures S3 as remote backend
- State is now stored in S3
- Locking uses DynamoDB

## Step 3: Deploy Dev Resources (When Ready)

```bash
# Still in dev/aws directory

# Review what will be created
terraform plan

# Create resources
terraform apply

# Destroy at end of day to save costs
terraform destroy
```

## Verification

```bash
# Check S3 bucket
aws s3 ls | grep hera-dev-tf-state

# Check DynamoDB table
aws dynamodb describe-table --table-name hera-dev-tf-lock --region us-east-1

# Check state file in S3
aws s3 ls s3://hera-dev-tf-state/
```

## Cost-Saving Workflow

### Start of Day
```bash
cd infra/terraform/envs/dev/aws
terraform apply -auto-approve
```

### End of Day
```bash
cd infra/terraform/envs/dev/aws
terraform destroy -auto-approve
```

## Current Status

✅ Bootstrap is ready to deploy
⚠️ Dev environment has no resources yet (network and EKS modules not implemented)

## Safety Check

Before running `terraform apply`, always:
1. Run `terraform plan` first
2. Review the output
3. Ensure changes match expectations

## Need Help?

See `DEPLOYMENT_GUIDE.md` for detailed documentation.
