# Automatic Kubeconfig Context Switching

The `infractl` CLI automatically switches to the correct kubeconfig context before running any Terraform command.

## Overview

When you run any Terraform operation (`plan`, `apply`, `destroy`) via `infractl`, it automatically:

1. **Detects** the required kubeconfig context based on the environment you're operating on
2. **Switches** to that context if needed
3. **Continues** with the Terraform operation

This eliminates the manual step of switching contexts and prevents deploying to the wrong cluster.

## How It Works

### Context Naming Convention

The system uses a consistent naming pattern for kubeconfig contexts:

| Environment | Pattern | Example |
|-------------|---------|---------|
| Local (KIND) | `hera-local` | `hera-local` |
| Cloud Environments | `hera-{env}` | `hera-dev`, `hera-staging`, `hera-prod` |
| Specialized | `hera-{env}` | `hera-playground` |

### Directory to Context Mapping

The CLI parses the Terraform directory path to determine the required context:

```
infra/terraform/envs/local/platform     → hera-local
infra/terraform/envs/dev/platform       → hera-dev
infra/terraform/envs/dev/aws/cluster    → hera-dev
infra/terraform/envs/staging/platform   → hera-staging
infra/terraform/envs/prod/aws/cluster   → hera-prod
```

### Example Behavior

```bash
# Start with dev context
$ kubectl config current-context
hera-dev

# Run terraform against local environment
$ infractl plan local platform
─── Hera :: Plan ────────────────────────────────
Environment: local
Stack:       platform
────────────────────────────────────────────────────
🔄 Switching kubeconfig context: hera-dev → hera-local
✔ Switched to context: hera-local

# Context has been switched automatically
$ kubectl config current-context
hera-local
```

## Benefits

### 1. **Safety**
- Prevents accidentally deploying to the wrong cluster
- No manual context switching required

### 2. **Convenience**
- Works transparently with all infractl commands
- Detects and switches automatically

### 3. **Consistency**
- Same behavior across all environments
- Clear naming convention

## Implementation Details

### Location in Code

The automatic context switching is implemented in:

- **Detection Logic**: `pkg/platform/kubeconfig/context.go`
  - `DetectContext()` - Determines required context from path
  - `SwitchContext()` - Switches to specified context
  - `GetCurrentContext()` - Gets current context

- **Integration**: `pkg/platform/terraform/runner.go`
  - `switchKubeconfigContext()` - Called before every terraform operation
  - Integrated into `Run()` function

### Error Handling

If context switching fails, the CLI:
- **Logs a warning** to stderr
- **Continues** with terraform operation (some stacks may not need k8s access)
- Shows clear error messages if context doesn't exist

Example warning:
```
⚠ Warning: Could not switch kubeconfig context: context 'hera-staging' not found in kubeconfig
```

## Adding New Environments

When adding a new environment, ensure your kubeconfig has a matching context:

1. **Create the environment directory**:
   ```bash
   mkdir -p infra/terraform/envs/staging/platform
   ```

2. **Add kubeconfig context** named `hera-staging`:
   ```bash
   # For AWS EKS
   aws eks update-kubeconfig --name hera-staging-eks --alias hera-staging

   # For Azure AKS
   az aks get-credentials --name hera-staging-aks --resource-group hera-rg --alias hera-staging

   # For GCP GKE
   gcloud container clusters get-credentials hera-staging-gke --zone us-central1-a --alias hera-staging
   ```

3. **Verify the context exists**:
   ```bash
   kubectl config get-contexts
   ```

4. **Use infractl normally**:
   ```bash
   infractl plan staging platform
   # Automatically uses hera-staging context
   ```

## Manual Override

If you need to bypass automatic switching:

1. **Use terraform directly** instead of infractl:
   ```bash
   cd infra/terraform/envs/dev/platform
   terraform plan
   ```

2. **Or set the context beforehand**:
   ```bash
   kubectl config use-context my-custom-context
   terraform plan
   ```

## Troubleshooting

### Context not found

**Error**: `context 'hera-dev' not found in kubeconfig`

**Solution**: Add the context to your kubeconfig:
```bash
aws eks update-kubeconfig --name hera-dev-eks --alias hera-dev
```

### Wrong context mapping

**Error**: Wrong cluster being selected

**Solution**: Check your directory structure matches the convention:
- `envs/{env}/{stack}` for single-cloud environments
- `envs/{env}/{cloud}/{stack}` for multi-cloud environments

### Context switching disabled

If you want to disable automatic switching, use terraform directly instead of infractl.

## Future Enhancements

Potential future improvements:
- Support for custom context naming patterns via config file
- Dry-run mode to show what context would be used
- Verification that cluster matches expected environment
- Multi-cluster operations
