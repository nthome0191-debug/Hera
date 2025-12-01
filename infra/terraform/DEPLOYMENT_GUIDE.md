# Hera Infrastructure Deployment Guide

This guide walks you through deploying the Hera infrastructure to AWS, with a focus on cost-efficient development practices.

## Architecture Overview

The infrastructure is split into two layers:

### 1. Bootstrap Layer (Persistent)
- **Location**: `envs/bootstrap/aws/`
- **Purpose**: Creates foundational resources for Terraform state management
- **Lifecycle**: Created once, never destroyed
- **Resources**:
  - S3 bucket for state storage
  - DynamoDB table for state locking
  - IAM admin role
- **Cost**: ~$1-2/month

### 2. Development Layer (Ephemeral)
- **Location**: `envs/dev/aws/`
- **Purpose**: Application infrastructure (VPC, EKS, etc.)
- **Lifecycle**: Can be destroyed nightly and recreated daily
- **Resources** (when implemented):
  - VPC and networking
  - EKS cluster
  - Application workloads
- **Cost**: Varies, but can be $0 when destroyed

## Why This Separation?

This architecture enables a cost-effective development workflow:

1. **Bootstrap resources** remain persistent and enable Terraform to function
2. **Dev resources** can be destroyed at end of day (5pm) and recreated next morning (9am)
3. **Save ~60% on development costs** by not running EKS overnight/weekends
4. **Single command** to destroy: `terraform destroy`
5. **Single command** to recreate: `terraform apply`

## Prerequisites

Before starting, ensure you have:

- [x] **AWS Account** with admin access
- [x] **AWS CLI** installed and configured
  ```bash
  aws --version
  aws configure
  ```
- [x] **Terraform** >= 1.6.0 installed
  ```bash
  terraform version
  ```
- [x] **AWS Account ID** noted (found in AWS Console or via `aws sts get-caller-identity`)

## Deployment Steps

### Phase 1: Bootstrap (One-Time Setup)

The bootstrap creates the foundation for Terraform state management.

#### Step 1: Navigate to Bootstrap Directory

```bash
cd infra/terraform/envs/bootstrap/aws
```

#### Step 2: Configure Variables

Edit `terraform.tfvars`:
```hcl
region         = "us-east-1"
aws_account_id = "628987527285"  # Your AWS account ID
project        = "hera"
environment    = "dev"
```

#### Step 3: Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create the resources
terraform apply
```

Type `yes` when prompted.

Expected output:
```
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:
bucket_name = "hera-dev-tf-state"
lock_table_name = "hera-dev-tf-lock"
admin_role_arn = "arn:aws:iam::628987527285:role/hera-dev-admin"
```

#### Step 4: Verify Resources

```bash
# Verify S3 bucket
aws s3 ls | grep hera-dev-tf-state

# Verify DynamoDB table
aws dynamodb describe-table --table-name hera-dev-tf-lock --region us-east-1

# Verify IAM role
aws iam get-role --role-name hera-dev-admin
```

#### Step 5: Backup Bootstrap State

The `terraform.tfstate` file in the bootstrap directory is critical. Back it up:

```bash
# Option 1: Commit to Git (if private repo)
git add terraform.tfstate
git commit -m "Add bootstrap state"

# Option 2: Backup to separate S3 bucket
aws s3 cp terraform.tfstate s3://your-backup-bucket/hera/bootstrap-backup/
```

### Phase 2: Development Environment

The dev environment will use the S3 backend created by bootstrap.

#### Step 1: Navigate to Dev Directory

```bash
cd ../../dev/aws
```

#### Step 2: Initialize with Remote Backend

```bash
terraform init
```

Terraform will:
- Configure the S3 backend
- Create initial state in S3
- Use DynamoDB for locking

You should see:
```
Initializing the backend...
Successfully configured the backend "s3"!
```

#### Step 3: Verify Backend Configuration

```bash
# Check that state is stored in S3
aws s3 ls s3://hera-dev-tf-state/
```

You should see the state file listed.

### Phase 3: Deploy Dev Resources (Future)

Once network and EKS modules are implemented:

```bash
# From infra/terraform/envs/dev/aws/

# Review changes
terraform plan

# Deploy infrastructure
terraform apply

# When done for the day, destroy to save costs
terraform destroy
```

## Daily Workflow (Once Implemented)

### Morning (Start of Work Day)

```bash
cd infra/terraform/envs/dev/aws
terraform apply -auto-approve
```

Estimated time: 10-15 minutes to create EKS cluster

### Evening (End of Work Day)

```bash
cd infra/terraform/envs/dev/aws
terraform destroy -auto-approve
```

Estimated time: 5-10 minutes to destroy all resources

### Cost Savings

Example calculation:
- EKS control plane: $0.10/hour × 24 hours = $2.40/day
- Worker nodes (2× t3.medium): $0.0416/hour each × 2 × 24 hours = $2.00/day
- Total daily cost: ~$4.40

**With destroy/recreate workflow:**
- Running 8 hours/day: $1.47/day
- Destroyed 16 hours/day: $0/day
- **Daily savings: $2.93 (~67%)**
- **Monthly savings: ~$88**

## Safety Checks

Before applying any changes:

### 1. Check What Will Change

```bash
terraform plan
```

Review the output carefully. Ensure:
- [ ] No unexpected deletions
- [ ] Resource counts match expectations
- [ ] No changes to production resources

### 2. Verify Current State

```bash
# Show current resources
terraform state list

# Show specific resource details
terraform state show <resource_name>
```

### 3. Check AWS Resources

```bash
# List VPCs
aws ec2 describe-vpcs --region us-east-1

# List EKS clusters
aws eks list-clusters --region us-east-1

# Check costs
aws ce get-cost-and-usage \
  --time-period Start=2025-11-01,End=2025-11-30 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## Current Status

As of now:

✅ **Completed:**
- Bootstrap module implemented and tested
- Bootstrap environment configured
- Dev environment configured for remote state
- Proper separation of persistent vs ephemeral resources

🚧 **TODO:**
- Implement network module (VPC, subnets, gateways)
- Implement EKS cluster module
- Implement platform base module (Kubernetes addons)
- Test full create/destroy cycle

## Is It Safe to Apply?

### Bootstrap Environment: ✅ YES - Safe to Apply

The bootstrap environment is ready to deploy:

```bash
cd infra/terraform/envs/bootstrap/aws
terraform init
terraform plan    # Review carefully
terraform apply   # Safe to proceed
```

**What will be created:**
- S3 bucket (no data loss risk, new resource)
- DynamoDB table (no data loss risk, new resource)
- IAM role (no security risk with current configuration)

**Estimated cost:** < $2/month

**Can be destroyed?** Only when completely done with the project

### Dev Environment: ⚠️ NOT YET - No Resources Defined

The dev environment currently has no resources defined (everything is commented out). Running `terraform apply` would create nothing.

**Next steps before deploying dev:**
1. Implement network module
2. Implement EKS module
3. Uncomment modules in `envs/dev/aws/main.tf`
4. Test with `terraform plan`
5. Then apply

## Troubleshooting

### Issue: Backend Initialization Failed

**Error:** `Error configuring the backend "s3": NoSuchBucket`

**Solution:** Bootstrap environment must be applied first:
```bash
cd infra/terraform/envs/bootstrap/aws
terraform apply
```

### Issue: State Lock Error

**Error:** `Error acquiring the state lock`

**Solution:** Someone else is running Terraform, or previous run didn't clean up:
```bash
# Check DynamoDB for locks
aws dynamodb scan --table-name hera-dev-tf-lock

# Force unlock (use with caution!)
terraform force-unlock <lock-id>
```

### Issue: Bucket Name Already Exists

**Error:** `BucketAlreadyExists: The requested bucket name is not available`

**Solution:** S3 bucket names are globally unique. Change in `envs/bootstrap/aws/terraform.tfvars`:
```hcl
project = "hera-yourname"  # Make it unique
```

## Best Practices

1. **Always run `terraform plan`** before `apply`
2. **Review destroy plans carefully** - ensure only ephemeral resources are destroyed
3. **Never destroy bootstrap** unless completely decommissioning
4. **Backup state files** regularly
5. **Use workspaces** for multiple environments (future enhancement)
6. **Tag all resources** consistently (already configured)
7. **Monitor costs** using AWS Cost Explorer

## Getting Help

- **Terraform AWS Provider Docs**: https://registry.terraform.io/providers/hashicorp/aws
- **Terraform Language Docs**: https://terraform.io/docs
- **AWS Documentation**: https://docs.aws.amazon.com
- **Project Issues**: Check the project repository

## Next Development Steps

To complete the infrastructure:

1. **Implement Network Module** (`modules/network/aws/main.tf`)
   - VPC with CIDR block
   - Public and private subnets across AZs
   - Internet gateway
   - NAT gateways
   - Route tables

2. **Implement EKS Module** (`modules/kubernetes-cluster/aws-eks/main.tf`)
   - EKS cluster
   - Node groups
   - IAM roles and policies
   - Security groups
   - OIDC provider for IRSA

3. **Implement Platform Module** (`modules/platform/base/main.tf`)
   - Core Kubernetes addons
   - Monitoring and logging
   - Ingress controllers

4. **Test Full Lifecycle**
   - Create all resources
   - Verify functionality
   - Destroy all dev resources
   - Recreate to confirm reproducibility

5. **Automate Daily Cycle**
   - Create scripts for morning apply
   - Create scripts for evening destroy
   - Consider AWS Lambda or GitHub Actions for scheduling
