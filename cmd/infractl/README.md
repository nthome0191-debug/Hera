# infractl — Hera Infrastructure Orchestration CLI

`infractl` is the command-line tool that manages all Terraform-based infrastructure environments in the Hera mono-repo. It provides safe, dependency-aware operations, module targeting, and consistent workflows across all cloud providers and environments.

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

## 13. Summary

`infractl` provides:

- Standardized infra operations
- Safe execution order
- Dependency validation
- Module targeting
- Multi-module orchestration
- Terraform-state-driven correctness
- Simple extensibility

It is the primary tool for provisioning and managing Hera platform infrastructure.
