================================================================================
Welcome to ${upper(project)} Infrastructure Access!
================================================================================

Your account has been created with AWS IAM Identity Center (SSO).
This provides secure, temporary credentials - no passwords or access keys needed!

== Step 1: Accept Email Invitation ==

1. Check your email for an AWS SSO invitation from no-reply@login.awsapps.com
2. Click the "Accept invitation" link
3. Create your password (one-time setup)
4. Set up MFA with an authenticator app (REQUIRED):
   - Google Authenticator
   - Authy
   - Microsoft Authenticator
   - 1Password

== Step 2: Configure AWS CLI for SSO ==

Run this command to configure SSO access:

   aws configure sso

When prompted, enter:
   SSO session name: ${project}
   SSO start URL: https://[your-identity-store-id].awsapps.com/start
   SSO region: ${region}
   SSO registration scopes: [press Enter for default]

Then select:
   - AWS Account: ${aws_account_id}
   - Role: [Your assigned role - Developer, InfraManager, etc.]
   - CLI default profile name: ${project}-${environment}

== Step 3: Daily Login (Start Here Each Day) ==

Each day (or when your 4-hour session expires), run:

   aws sso login --profile ${project}-${environment}

This will:
1. Open a browser window
2. Prompt for MFA authentication
3. Grant temporary AWS credentials (valid for 4 hours)

That's it! No more access keys, no more session tokens.

== Step 4: Kubernetes Access ==

After SSO login, configure kubectl:

   aws eks update-kubeconfig \
     --region ${region} \
     --name ${cluster_name} \
     --profile ${project}-${environment}

Test your access:

   kubectl get pods --all-namespaces

Your K8s permissions depend on your assigned permission set:
   - InfraManager: Full cluster-admin access
   - InfraMember: Read/write but not delete
   - Developer: Full access to 'dev' namespace, read elsewhere
   - SecurityEngineer: Read-only with security focus

== Step 5: Verify Your Access ==

Test AWS access:

   # Show your SSO identity
   aws sts get-caller-identity --profile ${project}-${environment}

   # List EKS clusters
   aws eks list-clusters --region ${region} --profile ${project}-${environment}

Test Kubernetes access:

   # List pods
   kubectl get pods -A

   # Check your permissions
   kubectl auth can-i create pods -n dev

== Quick Reference ==

Daily workflow:
   1. aws sso login --profile ${project}-${environment}
   2. [MFA in browser]
   3. Use aws/kubectl commands with --profile ${project}-${environment}

Session expired?
   → Just run: aws sso login --profile ${project}-${environment}

Multiple profiles?
   → List: aws configure list-profiles
   → Switch: export AWS_PROFILE=${project}-${environment}

== Permission Set Reference ==

InfraManager:
  AWS: Full infrastructure management (EC2, EKS, VPC, etc.)
       DENIED: Delete critical resources, IAM user management
  K8s: Full cluster-admin access

InfraMember:
  AWS: Read and modify existing resources
       DENIED: Create/delete clusters, IAM operations
  K8s: Full access except delete operations

Developer:
  AWS: Only EKS cluster authentication (DescribeCluster)
       DENIED: All other AWS operations
  K8s: %{ if environment == "dev" ~}
       Full access to 'dev' namespace
       Read-only access to other namespaces
       %{ else ~}
       Read-only access to all namespaces
       %{ endif ~}

SecurityEngineer:
  AWS: Read-only access to security services
       (CloudTrail, GuardDuty, Security Hub, Config, IAM analysis)
       DENIED: All write operations
  K8s: Read-only access with security focus

== Security Benefits of SSO ==

- NO static passwords for AWS access
- NO long-lived access keys
- Automatic MFA enforcement on every login
- Temporary credentials (4-hour expiry)
- Single sign-on across AWS services
- Centralized user management
- Audit trail for all logins

== Troubleshooting ==

Problem: "Token has expired" error
  → Run: aws sso login --profile ${project}-${environment}

Problem: Browser doesn't open
  → Copy the URL shown in terminal and paste in browser
  → Or use: aws sso login --profile ${project}-${environment} --no-browser

Problem: "No such profile" error
  → Re-run: aws configure sso
  → Verify profile name: aws configure list-profiles

Problem: kubectl permission denied
  → Verify SSO session is active: aws sts get-caller-identity --profile ${project}-${environment}
  → Re-run kubeconfig: aws eks update-kubeconfig ...
  → Check your permission set assignment

Problem: Can't find SSO invitation email
  → Check spam/junk folder
  → Email comes from: no-reply@login.awsapps.com
  → Contact DevOps team if not received within 24 hours

== Support ==

For access issues or questions:
  - DevOps Team: devops@company.com
  - Security Team: security@company.com
  - Documentation: https://github.com/yourorg/${project}/docs

== Important Notes ==

- Sessions expire after 4 hours - just re-login when needed
- MFA is enforced on every login - no way to bypass
- Your access is environment-specific: ${environment}
- SSO credentials are never stored locally in plain text

================================================================================
Welcome aboard! Enjoy the simplified, more secure login experience.
================================================================================
