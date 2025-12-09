# Dev Environment - Access Management

This directory manages user access for the **dev** environment.

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

## Adding a New User

1. Edit `terraform.tfvars` and add a new user entry:

```hcl
users = {
  # ... existing users ...

  "new.user" = {
    email               = "new.user@company.com"
    full_name           = "New User"
    roles               = ["developer"]
    require_mfa         = true
    console_access      = true
    programmatic_access = true
    environments        = ["dev"]
  }
}
```

2. Apply changes:
```bash
terraform apply
```

3. Share credentials with the user:
```bash
# Get password
aws secretsmanager get-secret-value \
  --secret-id hera/dev/users/new.user/initial-password \
  --query SecretString \
  --output text | jq -r '.initial_password'

# Get access keys
aws secretsmanager get-secret-value \
  --secret-id hera/dev/users/new.user/access-key \
  --query SecretString \
  --output text | jq -r '.'
```

4. Provide onboarding instructions:
```bash
terraform output kubeconfig_instructions
```

## Revoking Access

**Emergency (immediate):**
```bash
# Disable access key
aws iam update-access-key \
  --user-name username \
  --access-key-id AKIA... \
  --status Inactive

# Remove from groups
aws iam remove-user-from-group \
  --user-name username \
  --group-name hera-dev-infra-manager
```

**Permanent:**
1. Remove user from `terraform.tfvars`
2. Run `terraform apply`

## Available Roles

- **infra-manager**: Full AWS + K8s control (with safety denies)
- **infra-member**: Read/edit AWS, full K8s (no cluster deletion)
- **developer**: No AWS access, full dev namespace access
- **security-engineer**: Read-only all security services

## Developer Access in Dev Environment

Developers in the dev environment get:
- **AWS:** Only EKS cluster authentication (DescribeCluster)
- **K8s:** Full access to the `dev` namespace (all operations including exec)
- **K8s:** Read-only access to other namespaces

## Useful Commands

```bash
# List all users
terraform state list | grep aws_iam_user.users

# Show user details
terraform state show 'module.access_management.aws_iam_user.users["john.doe"]'

# Get console login URL
terraform output console_login_url

# Get all secret names
terraform output user_credentials_secrets

# Test K8s access
kubectl auth can-i create pods -n dev --as=alice.developer
```

## Troubleshooting

### aws-auth ConfigMap Issues
```bash
# Check ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml

# Verify node role is present
kubectl get configmap aws-auth -n kube-system -o jsonpath='{.data.mapRoles}'
```

### MFA Not Working
```bash
# Check MFA device
aws iam list-mfa-devices --user-name john.doe

# Get session token
aws sts get-session-token \
  --serial-number arn:aws:iam::ACCOUNT_ID:mfa/john.doe \
  --token-code 123456
```

## Integration with infractl

Once applied, users can access the cluster using:

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name hera-dev-CLUSTER_SUFFIX

# Or use infractl
infractl plan dev platform aws
```

## Important Notes

- Initial passwords must be changed on first login
- MFA is enforced - most operations blocked until configured
- Access keys should be rotated every 90 days
- All actions are logged in CloudTrail
- This configuration is for the **dev** environment only

## Support

For issues:
- Check module README: `../../../../modules/access-management/aws/README.md`
- Review plan file: `~/.claude/plans/`
