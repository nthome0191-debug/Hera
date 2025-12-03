# infractl — Hera Infrastructure Orchestration CLI

**Production-ready CLI for safe, dependency-aware Terraform operations across multi-cloud environments.**

`infractl` is the command-line orchestration tool for Hera infrastructure. It wraps Terraform with intelligent dependency management, automatic state inspection, and module targeting to prevent common operational mistakes (like destroying network before EKS, or applying EKS before network exists).

## Why infractl?

**Problems it solves:**
- ❌ Running `terraform destroy` on network while EKS cluster still exists
- ❌ Trying to apply EKS before network is created
- ❌ Forgetting which modules are already applied in an environment
- ❌ Managing dependencies manually across complex infrastructure stacks

**What infractl provides:**
- ✅ Automatic dependency enforcement (network → eks → platform)
- ✅ Reverse-order destroy protection (can't destroy network while EKS exists)
- ✅ State-driven module detection (knows what's applied)
- ✅ Module targeting (apply/destroy specific modules)
- ✅ Consistent workflow across all clouds and environments

## 1. Building the CLI

From the project root:

```
make build-infractl
```

This produces:

```
./bin/infractl
```

To install globally:

```
make install-infractl
```

This installs the binary into:

```
$GOPATH/bin/infractl
```

## 2. Shell Setup (zsh)

Edit:

```
~/.zshrc
```

Add:

```
export HERA_ROOT="$HOME/Projects/Hera"
export PATH="$HERA_ROOT/bin:$PATH"
```

Reload:

```
source ~/.zshrc
```

Now you can run:

```
infractl
```

from any terminal.

## 3. Infrastructure Layout

Expected structure:

```
infra/terraform/envs/<env>/<provider>
infra/terraform/modules/<stack>/<provider>
```

Examples:

```
infra/terraform/envs/bootstrap/aws/
infra/terraform/envs/dev/aws/
infra/terraform/envs/prod/aws/
```

Each environment is a Terraform root module composing:

- module.network
- module.eks_cluster
- module.platform_base (optional)

## 4. Cloud Credentials

Example AWS:

```
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

Or use:

```
aws sso login
```

## 5. Bootstrap (Required First Step)

Plan:

```
infractl plan aws bootstrap
```

Apply:

```
infractl apply aws bootstrap --auto-approve
```

No other environment works before bootstrap exists.

## 6. Managing Environments (dev / prod / staging)

```
infractl plan aws dev
infractl apply aws dev --auto-approve
infractl destroy aws dev --auto-approve
```

## 7. Module Targeting

```
network   → module.network
eks       → module.eks_cluster
platform  → module.platform_base
```

Examples:

```
infractl plan aws dev network
infractl plan aws dev network eks
infractl apply aws dev eks --auto-approve
infractl destroy aws dev eks --auto-approve
```

## 8. Automatic Dependency Enforcement

Dependencies enforced through Terraform state inspection:

1. Bootstrap → everything
2. Network → EKS
3. EKS → Platform
4. Reverse-order destroy protection

Examples:

```
infractl apply aws dev eks        → blocked
infractl destroy aws dev network  → blocked
```

## 9. Terraform Variable Files

```
--var-file=<file.tfvars>
```

Example:

```
infractl apply aws dev --var-file=terraform.tfvars.local --auto-approve
```

## 10. How infractl Detects Module State

State detection is derived from:

```
terraform state list
```

If results contain:

```
module.network.
```

then network is applied.

## 11. Extending infractl with New Stacks

```
var stackToModule = map[string]string{
    "network":  "module.network",
    "eks":      "module.eks_cluster",
    "platform": "module.platform_base",
}
```

```
var stackDeps = map[string][]string{
    "eks":      {"network"},
    "platform": {"eks"},
}
```

To add a stack:

```
stackToModule["kafka"] = "module.kafka"
stackDeps["kafka"] = []string{"network"}
```

## 12. Recommended Workflow

1. Configure shell (`HERA_ROOT`)
2. Build CLI
3. Apply bootstrap
4. Work on modules under `infra/terraform/modules`
5. Compose them in env main.tf
6. Test using:
   - infractl plan aws dev <module>
   - infractl apply aws dev <module>
7. Apply full environment
8. Extend maps for new stacks/modules

## 13. Common Workflow Examples

### Full Environment Lifecycle

```bash
# 1. Bootstrap (one-time)
infractl apply aws bootstrap --auto-approve

# 2. Create development environment
infractl apply aws dev --auto-approve

# 3. Destroy dev nightly to save costs
infractl destroy aws dev --auto-approve

# 4. Recreate dev next morning
infractl apply aws dev --auto-approve
```

### Incremental Module Deployment

```bash
# Deploy network first
infractl apply aws dev network --auto-approve

# Then EKS (depends on network)
infractl apply aws dev eks --auto-approve

# Later add platform components
infractl apply aws dev platform --auto-approve
```

### Safe Teardown

```bash
# This will FAIL (EKS exists)
infractl destroy aws dev network

# Correct order: destroy EKS first
infractl destroy aws dev eks --auto-approve

# Now network can be destroyed
infractl destroy aws dev network --auto-approve
```

### Testing Infrastructure Changes

```bash
# Test network module changes
infractl plan aws dev network

# Apply only network changes
infractl apply aws dev network --auto-approve

# Verify EKS still works
kubectl get nodes
```

---

## 14. Architecture & Design

### Dependency Graph

```
bootstrap
    ↓ (provides S3 backend)
network
    ↓ (provides VPC, subnets)
eks
    ↓ (provides K8s cluster)
platform
    ↓ (installs platform services)
```

### State Inspection Logic

`infractl` inspects Terraform state via `terraform state list` to determine:
- Which modules are currently applied
- Whether dependencies are satisfied
- Whether safe to destroy (no dependents)

**Example:**
```bash
$ terraform state list
module.network.aws_vpc.main
module.network.aws_subnet.private[0]
module.eks_cluster.aws_eks_cluster.main
```

`infractl` parses this output to know that both `network` and `eks` are deployed, so:
- ✅ Can apply `platform` (dependency satisfied)
- ❌ Cannot destroy `network` (EKS depends on it)

---

## 15. Summary

`infractl` provides:

- **Safe operations** - automatic dependency enforcement
- **State awareness** - knows what's deployed via Terraform state
- **Module targeting** - apply/destroy specific infrastructure layers
- **Cost efficiency** - enables daily teardown/recreation workflows
- **Multi-cloud ready** - consistent interface across AWS/Azure/GCP
- **Simple extensibility** - add new modules via Go maps

**Recommendation:** Always use `infractl` instead of direct `terraform` commands for Hera infrastructure. Direct Terraform usage is supported but lacks dependency protection.

---

## 16. Troubleshooting

### Error: "Module X depends on Y, which is not applied"

**Cause:** Trying to apply a module before its dependencies.

**Solution:**
```bash
# Apply dependencies first
infractl apply aws dev network --auto-approve
infractl apply aws dev eks --auto-approve
```

### Error: "Cannot destroy module X, dependent modules exist"

**Cause:** Trying to destroy a module that other modules depend on.

**Solution:**
```bash
# Destroy in reverse order
infractl destroy aws dev platform --auto-approve
infractl destroy aws dev eks --auto-approve
infractl destroy aws dev network --auto-approve
```

### Error: "command not found: infractl"

**Cause:** `infractl` not in PATH.

**Solution:**
```bash
# Add to shell rc file
export PATH="$HERA_ROOT/bin:$PATH"
source ~/.zshrc  # or ~/.bashrc
```

---

It is the **primary tool** for provisioning and managing Hera platform infrastructure.
