# Access Management Module - AWS

Manages IAM users, groups, policies, and Kubernetes RBAC for Hera infrastructure access control.

## Overview

This module provides comprehensive user access management with:
- **IAM user creation** with console and programmatic access
- **Role-based access control** (4 predefined roles)
- **Kubernetes RBAC integration** via aws-auth ConfigMap
- **MFA enforcement** for sensitive operations
- **Strict password policies**
- **Secure credential storage** in AWS Secrets Manager

## Features

### Security Hardening
✅ Principle of least privilege (explicit denies)

✅ MFA enforcement

✅ Strong password policy (16+ chars, complexity)

✅ Secrets in AWS Secrets Manager (not outputs)

✅ Deny destructive operations on critical resources

✅ Deny IAM user/role management

✅ Environment-specific RBAC (dev vs prod)

### Role Types

#### 1. Infra Manager
**AWS Permissions:**
- Full infrastructure management (EC2, EKS, VPC, ELB, CloudWatch, Logs, ECR)
- Read-only security access (CloudTrail, Config, GuardDuty, Security Hub)
- **DENIED:** Delete critical resources (S3 buckets, DynamoDB tables, CloudTrail)
- **DENIED:** IAM user/role/group creation
- **REQUIRES MFA:** For destructive operations (TerminateInstances, DeleteCluster)

**K8s Permissions:**
- Full cluster-admin access (mapped to `system:masters` group)

#### 2. Infra Member
**AWS Permissions:**
- Read all infrastructure resources
- Modify existing resources (UpdateNodegroup, ModifySecurityGroup, SetDesiredCapacity)
- **DENIED:** Create/delete clusters, VPCs, subnets, EC2 instances
- **DENIED:** All IAM operations

**K8s Permissions:**
- Full cluster access for read, create, update, delete
- Can exec into pods and view logs
- Cannot delete namespaces, nodes, or cluster-scoped resources

#### 3. Developer
**AWS Permissions:**
- **ONLY:** DescribeCluster, ListClusters (for kubectl authentication)
- **DENIED:** All other AWS operations

**K8s Permissions:**
- **Dev environment:** Full access to `dev` namespace (all verbs including exec)
- **Non-dev environments:** Read-only cluster-wide (get, list, watch)

#### 4. Security Engineer
**AWS Permissions:**
- Read-only access to all security services:
  - CloudTrail, GuardDuty, Security Hub, Config
  - IAM (policies, users, roles - analysis only)
  - Access Analyzer, Inspector
  - VPC Flow Logs
- **DENIED:** ALL write/create/delete operations (explicit deny)

**K8s Permissions:**
- Read-only cluster-wide access
- Focus on security resources (NetworkPolicies, PodSecurityPolicies, RBAC, events)

## Usage

### Module Instantiation

```hcl
module "access_management" {
  source = "../../../../modules/access-management/aws"

  environment    = "dev"
  region         = "us-east-1"
  aws_account_id = "123456789012"
  project        = "hera"

  cluster_name   = data.terraform_remote_state.cluster.outputs.cluster_name
  node_role_name = data.terraform_remote_state.cluster.outputs.node_iam_role_name

  users = {
    "john.doe" = {
      email               = "john.doe@company.com"
      full_name           = "John Doe"
      roles               = ["infra-manager"]
      require_mfa         = true
      console_access      = true
      programmatic_access = true
      environments        = ["dev", "staging", "prod"]
    }

    "jane.smith" = {
      email               = "jane.smith@company.com"
      full_name           = "Jane Smith"
      roles               = ["infra-member"]
      require_mfa         = true
      console_access      = true
      programmatic_access = true
      environments        = ["dev", "staging"]
    }

    "alice.developer" = {
      email               = "alice.developer@company.com"
      full_name           = "Alice Developer"
      roles               = ["developer"]
      require_mfa         = true
      console_access      = false
      programmatic_access = true
      environments        = ["dev"]
    }

    "bob.security" = {
      email               = "bob.security@company.com"
      full_name           = "Bob Security"
      roles               = ["security-engineer"]
      require_mfa         = true
      console_access      = true
      programmatic_access = true
      environments        = ["dev", "staging", "prod"]
    }
  }

  enforce_password_policy = true
  enforce_mfa            = true
  allowed_ip_ranges      = []  # Optional IP restriction

  tags = {
    Project     = "hera"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### Provider Configuration

The module requires both AWS and Kubernetes providers:

```hcl
provider "aws" {
  region = var.region
}

# Get EKS cluster info for K8s provider
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |
| kubernetes | ~> 2.35 |
| random | ~> 3.6 |

## Prerequisites

1. **Existing EKS cluster** with IRSA enabled
2. **CloudTrail enabled** (recommended)
3. **S3 remote state** configured
4. **Cluster module outputs** available via remote state

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, staging, prod) | string | - | yes |
| region | AWS region | string | - | yes |
| aws_account_id | AWS account ID | string | - | yes |
| project | Project name | string | "hera" | no |
| cluster_name | EKS cluster name | string | - | yes |
| node_role_name | IAM role name for EKS nodes | string | - | yes |
| users | Map of users to their role assignments | map(object) | {} | no |
| enforce_password_policy | Enforce strict password policy | bool | true | no |
| enforce_mfa | Enforce MFA for all users | bool | true | no |
| allowed_ip_ranges | List of allowed IP ranges for console access | list(string) | [] | no |
| tags | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_users | Map of created IAM users (ARN, name, unique_id) |
| iam_groups | Map of IAM group names |
| console_login_url | AWS Console login URL |
| user_credentials_secrets | Secrets Manager secret names for credentials |
| kubernetes_rbac_groups | Kubernetes RBAC groups created |
| kubeconfig_instructions | User onboarding instructions |

## User Management Workflows

### Adding a New User

1. Edit `envs/{env}/aws/access-management/terraform.tfvars`
2. Add user entry to `users` map:

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

3. Apply changes:
```bash
cd infra/terraform/envs/{env}/aws/access-management
terraform apply
```

4. Share credentials:
```bash
# Password
aws secretsmanager get-secret-value \
  --secret-id hera/{env}/users/new.user/initial-password

# Access keys
aws secretsmanager get-secret-value \
  --secret-id hera/{env}/users/new.user/access-key
```

### Revoking Access

**Immediate (Emergency):**
```bash
# Disable access keys
aws iam update-access-key \
  --user-name john.doe \
  --access-key-id AKIA... \
  --status Inactive

# Remove from groups
aws iam remove-user-from-group \
  --user-name john.doe \
  --group-name hera-dev-infra-manager
```

**Permanent:**
1. Remove user from `terraform.tfvars`
2. Run `terraform apply`
3. This will remove from groups, delete access keys, and remove from aws-auth

### Modifying User Roles

1. Edit the user's `roles` list in `terraform.tfvars`
2. Run `terraform apply`
3. Changes take effect immediately

## Security Considerations

### Included Protections
- ✅ Principle of least privilege with explicit denies
- ✅ MFA enforcement for sensitive operations
- ✅ Strong password policy (16+ chars)
- ✅ Credentials stored in Secrets Manager
- ✅ Deny destructive operations on critical resources
- ✅ Environment-specific RBAC

### Known Limitations
- ⚠️ **Access keys in Terraform state** - Ensure state is encrypted and access-controlled
- ⚠️ **Initial password delivery** - Users must retrieve from Secrets Manager
- ⚠️ **MFA setup window** - Limited capabilities before MFA configuration
- ⚠️ **Role changes require Terraform apply** - No self-service portal

### Compliance Alignment
- **SOC 2 / ISO 27001:** Least privilege, MFA, audit logging, segregation of duties
- **GDPR:** User data in VCS is intentional, access logs in CloudTrail

## Testing

### IAM Policy Testing
```bash
# Test infra-manager can create EC2 instances
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT_ID:user/john.doe \
  --action-names ec2:RunInstances

# Test developer CANNOT access S3
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT_ID:user/alice.developer \
  --action-names s3:ListBucket
```

### K8s RBAC Testing
```bash
# Test developer can create pods in dev namespace
kubectl auth can-i create pods -n dev --as=alice.developer
# Expected: yes

# Test developer CANNOT create pods in prod
kubectl auth can-i create pods -n prod --as=alice.developer
# Expected: no

# Test security engineer is read-only
kubectl auth can-i delete secrets -n kube-system --as=bob.security
# Expected: no
```

## Troubleshooting

### aws-auth ConfigMap Issues

If nodes can't join the cluster after applying:

1. Verify node role is in aws-auth:
```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```

2. Check node role ARN matches:
```bash
terraform output node_iam_role_arn
```

3. Manually fix if needed:
```bash
kubectl edit configmap aws-auth -n kube-system
```

### MFA Enforcement Issues

If users can't perform operations after MFA setup:

1. Verify MFA device is active:
```bash
aws iam list-mfa-devices --user-name john.doe
```

2. Test with session token:
```bash
aws sts get-session-token \
  --serial-number arn:aws:iam::ACCOUNT_ID:mfa/john.doe \
  --token-code 123456
```

### Secret Retrieval Issues

If secrets aren't accessible:

1. Check secret exists:
```bash
aws secretsmanager list-secrets --filters Key=name,Values=hera/dev/users/
```

2. Verify IAM permissions for Secrets Manager

## Migration from Existing Setup

If you have existing IAM users:

1. Import existing users:
```bash
terraform import 'module.access_management.aws_iam_user.users["john.doe"]' john.doe
```

2. Import group memberships:
```bash
terraform import 'module.access_management.aws_iam_user_group_membership.user_groups["john.doe"]' john.doe/hera-dev-infra-manager
```

3. Review and apply

## Cost Estimation

- **IAM:** Free (users, groups, policies)
- **Secrets Manager:** ~$0.40/secret/month
- **Total:** ~$0.40-$2.00/user/month (depending on console vs programmatic access)

## Support

For issues or questions:
- **Documentation:** See plan file at `~/.claude/plans/`
- **Source:** `/Users/nataliaharoni/Projects/Hera/infra/terraform/modules/access-management/aws/`

## License

Internal use only - Hera Infrastructure Project
