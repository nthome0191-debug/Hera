================================================================================
Welcome to ${upper(project)} Infrastructure Access!
================================================================================

Your account has been created in the ${environment} environment.
Follow these steps to get started:

== Step 1: AWS Console Access ==

1. Go to: ${console_url}
2. Account ID: ${aws_account_id}
3. IAM username: [YOUR_USERNAME]
4. Initial password: Retrieve from AWS Secrets Manager using:

   aws secretsmanager get-secret-value \
     --secret-id ${project}/${environment}/users/[YOUR_USERNAME]/initial-password \
     --query SecretString \
     --output text | jq -r '.initial_password'

5. You'll be required to change your password on first login

== Step 2: MFA Setup (REQUIRED) ==

MFA is REQUIRED - most operations will be blocked until you set it up!

1. Log into AWS Console
2. Go to: IAM → Users → [YOUR_USERNAME] → Security credentials
3. Click "Assign MFA device"
4. Choose "Virtual MFA device"
5. Use an authenticator app:
   - Google Authenticator
   - Authy
   - Microsoft Authenticator
   - 1Password
6. Scan the QR code
7. Enter two consecutive MFA codes
8. MFA setup complete!

== Step 3: AWS CLI Configuration (Programmatic Access) ==

1. Retrieve your access keys from Secrets Manager:

   aws secretsmanager get-secret-value \
     --secret-id ${project}/${environment}/users/[YOUR_USERNAME]/access-key \
     --query SecretString \
     --output text | jq -r '.'

2. Configure AWS CLI profile:

   aws configure --profile ${project}-${environment}

   AWS Access Key ID: [FROM_SECRETS_MANAGER]
   AWS Secret Access Key: [FROM_SECRETS_MANAGER]
   Default region: ${region}
   Default output format: json

3. Add MFA configuration to ~/.aws/config:

   [profile ${project}-${environment}]
   region = ${region}
   output = json
   mfa_serial = arn:aws:iam::${aws_account_id}:mfa/[YOUR_USERNAME]

4. To use the profile with MFA:

   aws sts get-session-token \
     --serial-number arn:aws:iam::${aws_account_id}:mfa/[YOUR_USERNAME] \
     --token-code [MFA_CODE] \
     --profile ${project}-${environment}

   # Export the temporary credentials
   export AWS_ACCESS_KEY_ID=[Credentials.AccessKeyId]
   export AWS_SECRET_ACCESS_KEY=[Credentials.SecretAccessKey]
   export AWS_SESSION_TOKEN=[Credentials.SessionToken]

== Step 4: Kubernetes Access ==

1. Update your kubeconfig:

   aws eks update-kubeconfig \
     --region ${region} \
     --name ${cluster_name} \
     --profile ${project}-${environment}

2. Test your access:

   kubectl get pods --all-namespaces

3. Your permissions depend on your assigned role:
   - Infra Manager: Full cluster-admin access
   - Infra Member: Read/write but not delete
   - Developer: Read-only (or full access to dev namespace in dev environment)
   - Security Engineer: Read-only security focus

== Step 5: Verify Your Access ==

Test your AWS permissions:

   # List EKS clusters
   aws eks list-clusters --region ${region}

   # Describe your IAM user
   aws iam get-user

Test your Kubernetes access:

   # List pods
   kubectl get pods -A

   # Check what you can do (example)
   kubectl auth can-i create pods -n dev

== Role-Specific Permissions ==

Infra Manager:
  AWS: Full infrastructure management (EC2, EKS, VPC, etc.)
       DENIED: Delete critical resources, IAM user management
  K8s: Full cluster-admin access

Infra Member:
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

Security Engineer:
  AWS: Read-only access to all security services
       (CloudTrail, GuardDuty, Security Hub, Config, IAM analysis)
       DENIED: All write operations
  K8s: Read-only access with security focus

== Security Best Practices ==

1. NEVER share your credentials
2. Enable MFA immediately (required)
3. Rotate access keys every 90 days
4. Use session tokens with MFA for CLI operations
5. Report suspicious activity immediately
6. Review CloudTrail logs regularly (security engineers)

== Troubleshooting ==

Problem: Can't log in to console
  → Verify you're using the correct Account ID: ${aws_account_id}
  → Double-check your username (case-sensitive)
  → Retrieve password from Secrets Manager

Problem: Operations are denied
  → Ensure MFA is set up and you're using it
  → Check if you're in the correct IAM group
  → Review your role permissions above

Problem: kubectl access denied
  → Verify kubeconfig is updated: kubectl config current-context
  → Check AWS credentials are valid: aws sts get-caller-identity
  → Confirm you're authenticated: kubectl auth whoami

Problem: Access key not working
  → Verify access keys from Secrets Manager
  → Check if MFA session token is required
  → Ensure credentials are not expired

== Support ==

For access issues or questions:
  - DevOps Team: devops@company.com
  - Security Team: security@company.com
  - Documentation: https://github.com/yourorg/${project}/docs

== Important Notes ==

- Initial passwords expire after first login
- Access keys should be rotated every 90 days
- MFA is enforced - you cannot perform most operations without it
- Your access is environment-specific: ${environment}

================================================================================
Welcome aboard! If you have any questions, don't hesitate to reach out.
================================================================================
