# Forking and Customizing This Infrastructure Project

This infrastructure project is designed to be fork-friendly and fully customizable for your organization. All references to the original project name can be easily replaced with your own.

## Quick Start: Automated Setup

The easiest way to customize this project after forking is to use the automated setup script:

```bash
./scripts/setup-fork.sh
```

This script will:
1. Prompt you for your project name, display name, and organization
2. Update the `project.yaml` configuration file
3. Update the Go module name and all import statements
4. Update Terraform variable defaults
5. Update Terraform tfvars files with your project name
6. Update Kubernetes RBAC group names
7. Update Kubernetes labels
8. Update CLI descriptions
9. Update AWS resource naming patterns

### What You'll Need

- Your project name (lowercase, no spaces, e.g., `myinfra`)
- Your display name (e.g., `MyInfra` or `Acme Infrastructure`)
- Your organization name (for LICENSE and documentation)

### Example

```bash
$ ./scripts/setup-fork.sh

==============================================================================
                  Infrastructure Project Fork Setup
==============================================================================

This script will help you customize this infrastructure project for your
organization by replacing all 'Hera' references with your project name.

Current project name: hera
Enter your new project name (lowercase, no spaces): acmeinfra
Enter your project display name (e.g., 'MyInfra'): Acme Infrastructure
Enter your organization name (for LICENSE): Acme Corporation

Summary of changes:
  Project name:      hera → acmeinfra
  Display name:      Hera → Acme Infrastructure
  Organization:      Hera Contributors → Acme Corporation

Proceed with these changes? (y/N): y
```

## What Gets Updated

### 1. Project Configuration (`project.yaml`)

The root configuration file that defines your project identity:

```yaml
project:
  name: "your-project-name"
  display_name: "Your Project Display Name"
  organization: "Your Organization"

kubernetes:
  rbac_group_prefix: "your-project-name"
  platform_label: "your-project-name-platform"

aws:
  dynamodb_table_prefix: "your-project-name"
  s3_bucket_prefix: "your-project-name"
```

### 2. Go Module and Imports

- **go.mod**: Module name changes from `hera` to `your-project-name`
- **All .go files**: Import paths update from `hera/...` to `your-project-name/...`

Example:
```go
// Before
import "hera/cli/infractl/cmd"
import "hera/internal/resolver"

// After
import "acmeinfra/cli/infractl/cmd"
import "acmeinfra/internal/resolver"
```

### 3. Terraform Variables and Values

- **Variable defaults**: All `project` variable defaults in `variables.tf` files
- **Terraform tfvars**: Project name in all `.tfvars` files
- **Cluster names**: Updated from `hera-{env}` to `{yourproject}-{env}`
- **Kubeconfig contexts**: Updated from `hera-dev` to `{yourproject}-dev`

Example:
```hcl
# Before
project     = "hera"
cluster_name = "hera-dev-eks"
kubeconfig_context_name = "hera-dev"

# After
project     = "acmeinfra"
cluster_name = "acmeinfra-dev-eks"
kubeconfig_context_name = "acmeinfra-dev"
```

### 4. Kubernetes RBAC Groups

All Kubernetes RBAC group names update to use your project prefix:

```yaml
# Before
hera:infra-managers
hera:infra-members
hera:developers
hera:security-engineers

# After
acmeinfra:infra-managers
acmeinfra:infra-members
acmeinfra:developers
acmeinfra:security-engineers
```

### 5. Kubernetes Labels

```yaml
# Before
app.kubernetes.io/part-of: hera-platform

# After
app.kubernetes.io/part-of: acmeinfra-platform
```

### 6. AWS Resource Names

Naming patterns for AWS resources update throughout:

```
# DynamoDB lock tables
hera-dev-tf-lock → acmeinfra-dev-tf-lock
hera-staging-tf-lock → acmeinfra-staging-tf-lock

# S3 state buckets
hera-dev-tf-state → acmeinfra-dev-tf-state
hera-staging-tf-state → acmeinfra-staging-tf-state
```

### 7. CLI Description

```go
// Before
Short: "Hera infrastructure CLI"

// After
Short: "Acme Infrastructure infrastructure CLI"
```

## Manual Updates After Setup

After running the setup script, you should manually update:

### 1. Documentation

- **README.md**: Update with your project description, goals, and specific details
- **LICENSE**: Update copyright holder to your organization
- **IMPLEMENTATION_SUMMARY.md**: Update or remove based on your needs

### 2. GitOps Repository References

If you're using ArgoCD or GitOps, update the repository URLs:

- Search for `Hera-gitops` and update to your GitOps repository name
- Update in Terraform state and ArgoCD application manifests

### 3. Operator Placeholder Comments

In the `operators/` directory, update placeholder import comments:

```go
// Before
// import cachev1alpha1 "github.com/yourorg/hera/operators/redis-operator/api/v1alpha1"

// After
// import cachev1alpha1 "github.com/yourorg/acmeinfra/operators/redis-operator/api/v1alpha1"
```

### 4. Support and Documentation Links

Update any email addresses or support links in:
- `infra/terraform/modules/cluster-auth-mapping/aws-eks/templates/user-onboarding.tpl`
- Any custom documentation you add

## Verification

After setup, verify the changes:

### 1. Check Go Module

```bash
# Should show your new module name
head -1 go.mod

# Update dependencies
go mod tidy

# Build the CLI
make build-infractl
```

### 2. Check Terraform Variables

```bash
# Search for your project name
grep -r "project.*=" infra/terraform/envs/

# Ensure no hardcoded "hera" references remain (except in documentation)
grep -r "hera" infra/terraform/ | grep -v ".tfstate" | grep -v "# "
```

### 3. Check RBAC Groups

```bash
grep -r "hera:" infra/terraform/modules/kubernetes-rbac/
# Should show your project name instead
```

## Terraform Backend Configuration

Don't forget to create your backend configuration files:

```bash
# Copy the examples
cp infra/terraform/envs/dev/aws/cluster/backend.tf.example \
   infra/terraform/envs/dev/aws/cluster/backend.tf

# Update with your values
# The setup script already updated the example files with your project name
```

Example `backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "acmeinfra-dev-tf-state-123456789012"
    key            = "cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acmeinfra-dev-tf-lock-123456789012"
    encrypt        = true
  }
}
```

## Rollback

If you need to rollback the setup:

1. The script creates a backup: `project.yaml.backup`
2. Use git to revert all changes:
   ```bash
   git checkout .
   git clean -fd
   ```

## Troubleshooting

### Import Errors After Renaming Go Module

```bash
# Clear the Go module cache
go clean -modcache

# Re-download dependencies
go mod download

# Tidy up
go mod tidy
```

### Terraform State Shows Old Project Name

This is expected if you already have infrastructure deployed. The project name in tfvars and variables controls new resources. Existing resources can be renamed through Terraform or left as-is.

### sed: command not found (on some systems)

The setup script uses `sed` for file modifications. On macOS, ensure you have the command-line tools installed:

```bash
xcode-select --install
```

## Next Steps

After customizing the project:

1. ✅ Run `go mod tidy`
2. ✅ Build and test the CLI: `make build-infractl`
3. ✅ Review and update README.md
4. ✅ Update LICENSE with your organization
5. ✅ Create backend configuration for Terraform
6. ✅ Initialize Terraform: `terraform init` in each environment
7. ✅ Commit all changes to your fork
8. ✅ Set up your AWS account and credentials
9. ✅ Deploy your infrastructure!

## Support

For issues with the setup script or customization process, please open an issue in your fork's repository.
