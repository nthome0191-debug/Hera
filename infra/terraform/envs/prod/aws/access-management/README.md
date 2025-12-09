# Production Environment - Access Management

This directory manages user access for the **production** environment.

## ⚠️ PRODUCTION ENVIRONMENT - CRITICAL ⚠️

This is the production environment. Exercise extreme caution:
- Minimize user access (only essential personnel)
- Enable IP restrictions for console access
- Review all changes carefully before applying
- All actions are logged and monitored
- Follow change management procedures

## Setup

1. **Copy backend configuration:**
   ```bash
   cp backend.tf.example backend.tf
   # Edit backend.tf and replace YOUR_ACCOUNT_ID with your AWS account ID
   ```

2. **Copy terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and configure your users (MINIMAL ACCESS)
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan CAREFULLY:**
   ```bash
   terraform plan
   # Review every change thoroughly
   ```

5. **Apply with approval:**
   ```bash
   terraform apply
   # Confirm changes are correct
   ```

## Production Security Guidelines

### User Access
- **Minimal Principle:** Only grant prod access to essential personnel
- **Infra Managers:** Senior infrastructure engineers only
- **No Developers:** Developers should NOT have direct prod access
- **Security Team:** Full read-only security access for auditing
- **Emergency Access:** Document break-glass procedures separately

### IP Restrictions (RECOMMENDED)
Enable `allowed_ip_ranges` in `terraform.tfvars`:
```hcl
allowed_ip_ranges = [
  "1.2.3.4/32",     # Office IP
  "5.6.7.8/32",     # VPN IP
]
```

### MFA (REQUIRED)
- MFA is mandatory for all production users
- No exceptions
- MFA devices must be backed up

## Available Roles

- **infra-manager**: Full AWS + K8s control (with safety denies)
- **infra-member**: Read/edit AWS, full K8s (no cluster deletion)
- **developer**: NO DIRECT PROD ACCESS (use CI/CD instead)
- **security-engineer**: Read-only all security services

## Developer Access in Production

Developers should **NOT** have direct production access:
- **AWS:** Denied
- **K8s:** Denied
- **Deployments:** Via CI/CD pipelines only (ArgoCD, GitHub Actions)

If absolutely necessary (emergency only):
- Grant temporary `developer` role
- Read-only K8s access only (get, list, watch)
- Revoke immediately after emergency

## Change Management

All production changes must:
1. Be reviewed by at least 2 team members
2. Have a change ticket/approval
3. Be tested in staging first
4. Follow the 4-eyes principle
5. Be documented in change log

## Useful Commands

```bash
# ALWAYS review before applying
terraform plan

# List all users
terraform state list | grep aws_iam_user.users

# Get console login URL
terraform output console_login_url

# Audit: Check who has prod access
aws iam list-users | jq -r '.Users[].UserName' | grep -v "^aws-"
```

## Monitoring & Auditing

### CloudTrail
All production actions are logged. Review regularly:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --max-items 20
```

### Failed Authentications
Monitor failed login attempts:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --max-items 50 | jq '.Events[] | select(.CloudTrailEvent | contains("Failed"))'
```

### Access Reviews
Conduct quarterly access reviews:
1. List all production users
2. Verify each user still needs access
3. Remove inactive users
4. Rotate access keys

## Emergency Procedures

### Break-Glass Access
If regular authentication fails:
1. Use root account credentials (stored securely)
2. Create temporary admin user
3. Fix the issue
4. Remove temporary access
5. Document the incident

### Revoke Access Immediately
```bash
# Disable access key
aws iam update-access-key \
  --user-name username \
  --access-key-id AKIA... \
  --status Inactive

# Remove from all groups
aws iam remove-user-from-group \
  --user-name username \
  --group-name hera-prod-infra-manager
```

## Important Notes

- ⚠️ **PRODUCTION ENVIRONMENT** - Exercise extreme caution
- Minimize user count (principle of least privilege)
- Enable IP restrictions
- MFA is mandatory (no exceptions)
- All actions are logged and monitored
- Follow change management procedures
- Review access quarterly
- Rotate credentials every 60 days (stricter than dev/staging)

## Compliance

Production access must comply with:
- SOC 2 requirements
- ISO 27001 standards
- GDPR (if applicable)
- Internal security policies

## Support

For production issues:
- **Emergency:** Escalate to on-call engineer
- **Access Requests:** Follow formal change management
- **Security Incidents:** Contact security team immediately
- **Documentation:** Check module README and plan file

## Audit Trail

Keep a log of all access changes:
```bash
# Log format
Date: YYYY-MM-DD
Change: Added/Removed user X
Reason: [Business justification]
Approver: [Manager name]
Applied By: [Engineer name]
```
