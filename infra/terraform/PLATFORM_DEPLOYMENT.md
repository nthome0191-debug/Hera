# Platform Deployment Guide - Option C: Kubeconfig-Based

This document describes how to deploy the platform (ArgoCD, etc.) to any cloud provider cluster using kubeconfig-based authentication.

## Architecture

```
infractl apply <env> platform <cloud>
    ↓
1. Read cluster outputs
   → kubeconfig_path
   → kubeconfig_context
    ↓
2. Set environment variables
   → KUBECONFIG
   → TF_VAR_kubeconfig_path
   → TF_VAR_kubeconfig_context
    ↓
3. Apply platform
   → Providers connect via kubeconfig
```

## Changes Made

### 1. Cluster Module Outputs

All cluster modules now output:
- `kubeconfig_path` - Path to kubeconfig file
- `kubeconfig_context` - Context name for the cluster

**Files Updated:**
- `modules/kubernetes-cluster/aws-eks/outputs.tf`
- `modules/kubernetes-cluster/local-kind/outputs.tf`
- `envs/dev/aws/cluster/outputs.tf`
- `envs/local/cluster/outputs.tf`

### 2. Platform Module Variables

Platform modules now accept:
- `kubeconfig_path` - Required, path to kubeconfig
- `kubeconfig_context` - Optional, context to use

**Files Updated:**
- `envs/dev/platform/variables.tf`
- `envs/dev/platform/providers.tf`
- `envs/local/platform/variables.tf`
- `envs/local/platform/providers.tf`

### 3. Provider Configuration

Providers now use kubeconfig with optional context:

```hcl
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
  }
}
```

## CLI Implementation

### Pseudo-code

```python
#!/usr/bin/env python3
import subprocess
import os
import sys

def get_terraform_output(directory, output_name):
    """Get terraform output from a directory"""
    result = subprocess.run(
        ["terraform", "output", "-raw", output_name],
        cwd=directory,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        raise Exception(f"Failed to get {output_name}: {result.stderr}")
    return result.stdout.strip()

def apply_platform(env, cloud):
    """Deploy platform to specified environment and cloud"""

    # 1. Resolve paths
    cluster_dir = f"envs/{env}/{cloud}/cluster"
    platform_dir = f"envs/{env}/platform"

    print(f"Deploying platform to {env}/{cloud}")
    print(f"Cluster config: {cluster_dir}")
    print(f"Platform config: {platform_dir}")

    # 2. Get cluster outputs
    print("Reading cluster configuration...")
    kubeconfig_path = get_terraform_output(cluster_dir, "kubeconfig_path")
    kubeconfig_context = get_terraform_output(cluster_dir, "kubeconfig_context")

    print(f"Kubeconfig path: {kubeconfig_path}")
    print(f"Kubeconfig context: {kubeconfig_context}")

    # 3. Set environment variables
    env_vars = os.environ.copy()
    env_vars["KUBECONFIG"] = kubeconfig_path
    env_vars["TF_VAR_kubeconfig_path"] = kubeconfig_path
    env_vars["TF_VAR_kubeconfig_context"] = kubeconfig_context

    # 4. Verify kubectl can connect
    print("Verifying cluster access...")
    result = subprocess.run(
        ["kubectl", "cluster-info", "--context", kubeconfig_context],
        env=env_vars,
        capture_output=True
    )
    if result.returncode != 0:
        raise Exception("Cannot connect to cluster. Check cluster is running and kubeconfig is valid.")

    # 5. Apply platform
    print(f"Applying platform to {kubeconfig_context}...")
    result = subprocess.run(
        ["terraform", "apply"],
        cwd=platform_dir,
        env=env_vars
    )

    if result.returncode == 0:
        print(f"✅ Platform deployed successfully to {env}/{cloud}")
    else:
        print(f"❌ Platform deployment failed")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[2] != "platform":
        print("Usage: infractl apply <env> platform <cloud>")
        print("Example: infractl apply dev platform aws")
        sys.exit(1)

    env = sys.argv[1]
    cloud = sys.argv[3]

    apply_platform(env, cloud)
```

### Save as `infractl.py`

```bash
# Make it executable
chmod +x infractl.py

# Use it
./infractl.py apply dev platform aws
./infractl.py apply production platform gcp
./infractl.py apply local platform local
```

## Manual Usage (Without CLI)

### Example 1: Deploy to dev AWS

```bash
# Step 1: Get cluster outputs
cd envs/dev/aws/cluster
KUBECONFIG_PATH=$(terraform output -raw kubeconfig_path)
KUBECONFIG_CONTEXT=$(terraform output -raw kubeconfig_context)

# Step 2: Deploy platform
cd ../../platform
export KUBECONFIG="$KUBECONFIG_PATH"
terraform apply \
  -var="kubeconfig_path=$KUBECONFIG_PATH" \
  -var="kubeconfig_context=$KUBECONFIG_CONTEXT"
```

### Example 2: Deploy to local kind

```bash
# Step 1: Get cluster outputs
cd envs/local/cluster
KUBECONFIG_PATH=$(terraform output -raw kubeconfig_path)
KUBECONFIG_CONTEXT=$(terraform output -raw kubeconfig_context)

# Step 2: Deploy platform
cd ../platform
export KUBECONFIG="$KUBECONFIG_PATH"
terraform apply \
  -var="kubeconfig_path=$KUBECONFIG_PATH" \
  -var="kubeconfig_context=$KUBECONFIG_CONTEXT"
```

### Example 3: Deploy to production GCP

```bash
# Step 1: Get cluster outputs
cd envs/production/gcp/cluster
KUBECONFIG_PATH=$(terraform output -raw kubeconfig_path)
KUBECONFIG_CONTEXT=$(terraform output -raw kubeconfig_context)

# Step 2: Deploy platform
cd ../../platform
export KUBECONFIG="$KUBECONFIG_PATH"
terraform apply \
  -var="kubeconfig_path=$KUBECONFIG_PATH" \
  -var="kubeconfig_context=$KUBECONFIG_CONTEXT"
```

## Testing

### 1. Test Cluster Outputs

```bash
# AWS EKS
cd envs/dev/aws/cluster
terraform output kubeconfig_path
terraform output kubeconfig_context

# Local kind
cd envs/local/cluster
terraform output kubeconfig_path
terraform output kubeconfig_context
```

### 2. Test Platform Deployment

```bash
# Deploy to local kind first (safer for testing)
cd envs/local/cluster
terraform apply

cd ../platform
export KUBECONFIG=$(cd ../cluster && terraform output -raw kubeconfig_path)
terraform apply \
  -var="kubeconfig_path=$(cd ../cluster && terraform output -raw kubeconfig_path)" \
  -var="kubeconfig_context=$(cd ../cluster && terraform output -raw kubeconfig_context)"
```

### 3. Verify Deployment

```bash
# Check ArgoCD is running
kubectl get pods -n argocd --context <kubeconfig_context>

# Get ArgoCD admin password
cd envs/<env>/platform
terraform output -raw argocd_admin_password

# Port-forward to ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443 --context <kubeconfig_context>

# Access at https://localhost:8080
```

## Benefits of This Approach

✅ **Single platform definition** - No code duplication across clouds
✅ **Explicit targeting** - Always know which cluster you're deploying to
✅ **Standard tooling** - Uses kubeconfig, works with kubectl
✅ **Safe** - Can't accidentally deploy to wrong cluster
✅ **Cloud agnostic** - Same code works on AWS, Azure, GCP, local
✅ **Developer friendly** - Uses familiar kubectl config

## Troubleshooting

### Issue: "Cannot connect to cluster"

```bash
# Check cluster is running
kubectl cluster-info --context <kubeconfig_context>

# Check kubeconfig has correct context
kubectl config get-contexts

# Manually set context
kubectl config use-context <kubeconfig_context>
```

### Issue: "Kubeconfig context not found"

```bash
# List available contexts
kubectl config get-contexts

# Check cluster outputs match
cd envs/<env>/<cloud>/cluster
terraform output kubeconfig_context
```

### Issue: "Platform fails to connect"

```bash
# Verify environment variables are set
echo $KUBECONFIG
echo $TF_VAR_kubeconfig_path
echo $TF_VAR_kubeconfig_context

# Test kubectl can connect
kubectl get nodes --context $TF_VAR_kubeconfig_context
```

## Multi-Cloud Platform Deployment

With this approach, you can deploy the same platform to multiple clouds:

```bash
# Deploy to all dev environments
./infractl.py apply dev platform aws
./infractl.py apply dev platform azure
./infractl.py apply dev platform gcp
./infractl.py apply dev platform local

# Each gets the same ArgoCD, but connected to different cluster
```

## Next Steps

1. Implement the `infractl.py` CLI script
2. Add validation and error handling
3. Add support for `terraform plan` before apply
4. Add support for `terraform destroy`
5. Add configuration file for defaults (e.g., `.infractl.yaml`)
6. Consider adding `--auto-approve` flag
