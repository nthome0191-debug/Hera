# Bootstrap Environment - AWS

**⚠️ CRITICAL: This must be applied FIRST before any other infrastructure.**

This directory contains the foundational infrastructure required for Terraform remote state management. It creates persistent resources (~$1-2/month) that enable all other environments to use S3-backed remote state with locking.

## What This Creates

This bootstrap environment creates persistent resources that should **never be destroyed**:

1. **S3 Bucket** (`hera-dev-tf-state`)
   - Stores Terraform state files for the dev environment
   - Versioning enabled for state history
   - Server-side encryption (AES256)
   - Public access completely blocked

2. **DynamoDB Table** (`hera-dev-tf-lock`)
   - Provides state locking to prevent concurrent modifications
   - Pay-per-request billing mode (cost-effective)
   - Hash key: `LockID`

3. **IAM Admin Role** (`hera-dev-admin`)
   - Administrative role for managing infrastructure
   - Can be assumed by your AWS account root user
   - Attached to AdministratorAccess policy

## Architecture Pattern

```
┌─────────────────────────────────────┐
│   Bootstrap Environment (Persistent) │
│   - S3 Bucket                        │
│   - DynamoDB Table                   │
│   - IAM Role                         │
│   State: LOCAL                       │
└─────────────────────────────────────┘
              ↓ provides backend
┌─────────────────────────────────────┐
│   Dev Environment (Ephemeral)       │
│   - VPC & Networking                 │
│   - EKS Cluster                      │
│   - Application Resources            │
│   State: S3 (remote)                 │
└─────────────────────────────────────┘
```

## Prerequisites

1. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```

2. **Terraform** version >= 1.6.0
   ```bash
   terraform version
   ```

3. **AWS Account ID** - You need to know your AWS account ID

4. **Permissions** - Your AWS credentials need:
   - S3: CreateBucket, PutBucketVersioning, PutEncryptionConfiguration, etc.
   - DynamoDB: CreateTable
   - IAM: CreateRole, AttachRolePolicy

## Initial Setup

**Recommended:** Use `infractl` for streamlined operations:

```bash
# Build infractl first
cd $HERA_ROOT
make build-infractl

# Apply bootstrap
infractl plan aws bootstrap
infractl apply aws bootstrap --auto-approve
```

**Alternative:** Direct Terraform usage (shown below).

---

### Step 1: Configure Variables

Update `terraform.tfvars` with your values:
```hcl
region         = "us-east-1"
aws_account_id = "YOUR_ACCOUNT_ID_HERE"
project        = "hera"
environment    = "dev"
```

### Step 2: Initialize Terraform

```bash
cd /path/to/Hera/infra/terraform/envs/bootstrap/aws
terraform init
```

This will:
- Download the AWS provider
- Initialize the working directory
- Use local state (stored in `terraform.tfstate`)

### Step 3: Review the Plan

```bash
terraform plan
```

Review the resources that will be created:
- `aws_s3_bucket.tf_state`
- `aws_s3_bucket_versioning.versioning`
- `aws_s3_bucket_server_side_encryption_configuration.enc`
- `aws_s3_bucket_public_access_block.block`
- `aws_dynamodb_table.tf_lock`
- `aws_iam_role.admin_role`
- `aws_iam_role_policy_attachment.admin_role_attach`

### Step 4: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.

This will create the bootstrap resources. The output will show:
- `bucket_name`: S3 bucket for state storage
- `lock_table_name`: DynamoDB table for locking
- `admin_role_arn`: IAM role ARN
- `backend_config`: Configuration for other environments

### Step 5: Save the State File

**CRITICAL**: The `terraform.tfstate` file in this directory contains the state for your bootstrap resources. This file must be preserved!

Options for protecting it:
1. **Commit to Git** (if private repository)
2. **Store in secure location** (encrypted backup)
3. **Upload to S3** (different bucket, for disaster recovery)

Example backup:
```bash
# Optional: backup to a personal S3 bucket
aws s3 cp terraform.tfstate s3://my-backup-bucket/hera/bootstrap-state-backup/
```

## Verification

After applying, verify the resources were created:

```bash
# Check S3 bucket
aws s3 ls | grep hera-dev-tf-state

# Check DynamoDB table
aws dynamodb describe-table --table-name hera-dev-tf-lock

# Check IAM role
aws iam get-role --role-name hera-dev-admin
```

## Next Steps

Once the bootstrap is complete:

1. Navigate to the dev environment:
   ```bash
   cd ../../dev/aws
   ```

2. Initialize with the S3 backend:
   ```bash
   terraform init
   ```

3. The dev environment will now use the S3 bucket for remote state

## State Storage

- **Local State**: This bootstrap environment uses LOCAL state
- **State File**: `terraform.tfstate` (in this directory)
- **Why Local**: Can't use S3 backend before the S3 bucket exists!

## Cost Considerations

Monthly costs (approximate, us-east-1):
- S3 bucket: ~$0.023/GB + requests (minimal for state files)
- DynamoDB: Pay-per-request (~$1.25 per million requests, likely < $1/month)
- IAM role: FREE

**Total estimated cost: < $1-2/month**

## Modifications

If you need to modify bootstrap resources:

```bash
# Make changes to variables or module
terraform plan
terraform apply
```

## Destruction

**WARNING**: Only destroy if you're completely done with the project!

```bash
# This will destroy the S3 bucket and DynamoDB table
# Make sure no other environments are using them!
terraform destroy
```

Before destroying:
1. Ensure all other environments are destroyed
2. Backup any important state files
3. Verify no resources depend on this infrastructure

## Troubleshooting

### Error: "Bucket already exists"
- The bucket name must be globally unique
- Try changing the `project` or `environment` variable

### Error: "Access Denied"
- Verify your AWS credentials have sufficient permissions
- Check `aws sts get-caller-identity` to confirm your identity

### State File Issues
- Never delete `terraform.tfstate` manually
- Keep backups of this file
- Don't edit the state file directly

## Security Notes

1. S3 bucket is encrypted at rest (AES256)
2. Public access is completely blocked
3. Versioning is enabled (can recover from mistakes)
4. IAM role follows principle of least privilege (for its purpose)

## Support

For issues or questions:
1. Review Terraform documentation: https://terraform.io/docs
2. Check AWS provider docs: https://registry.terraform.io/providers/hashicorp/aws
3. Review module source code in `modules/bootstrap/aws/`
