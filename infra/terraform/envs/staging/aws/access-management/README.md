# Staging Environment - Access Management

This directory manages user access for the **staging** environment.

## Setup

1. **Copy backend configuration:**
   ```bash
   cp backend.tf.example backend.tf
   # Edit backend.tf and replace YOUR_ACCOUNT_ID with your AWS account ID
   ```

2. **Copy terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and configure your users
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Key Differences from Dev

- **Environment:** staging
- **Developer Access:** Developers get **read-only** access to all namespaces (no full namespace access like in dev)
- **Security:** Stricter controls, consider enabling IP restrictions
- **Users:** Typically fewer developers, more infra team members

## Available Roles

- **infra-manager**: Full AWS + K8s control (with safety denies)
- **infra-member**: Read/edit AWS, full K8s (no cluster deletion)
- **developer**: No AWS access, read-only K8s access
- **security-engineer**: Read-only all security services

## Developer Access in Staging Environment

Developers in the staging environment get:
- **AWS:** Only EKS cluster authentication (DescribeCluster)
- **K8s:** Read-only access to all namespaces (get, list, watch only)
- **K8s:** NO create/update/delete/exec permissions

## Useful Commands

```bash
# List all users
terraform state list | grep aws_iam_user.users

# Get console login URL
terraform output console_login_url

# Get all secret names
terraform output user_credentials_secrets

# Test K8s access
kubectl auth can-i create pods -n staging --as=alice.developer
# Expected: no (developers are read-only in staging)
```

## Important Notes

- This is the **staging** environment - production-like security
- Developers have read-only K8s access (no write operations)
- Consider enabling IP restrictions for console access
- All actions are logged in CloudTrail
- Access keys should be rotated every 90 days

## Support

For issues:
- Check module README: `../../../../modules/access-management/aws/README.md`
- Review plan file: `~/.claude/plans/`
