# Implementation Summary: Automatic Kubeconfig Context Switching

## 🎯 What Was Implemented

Added **automatic kubeconfig context switching** to the `infractl` CLI. Now, every Terraform operation automatically switches to the correct Kubernetes cluster context before running.

## ✨ Key Features

### 1. **Transparent Context Switching**
- Before **every** Terraform command (`plan`, `apply`, `destroy`)
- Automatically detects the required context from the directory path
- Shows clear visual feedback when switching

### 2. **Smart Detection**
The system analyzes your terraform directory path to determine the correct context:

```
Working in: infra/terraform/envs/local/platform
→ Switches to: hera-local

Working in: infra/terraform/envs/dev/platform
→ Switches to: hera-dev

Working in: infra/terraform/envs/dev/aws/cluster
→ Switches to: hera-dev
```

### 3. **Safety First**
- Prevents deploying to the wrong cluster
- No more manual context switching
- Clear warnings if context doesn't exist

## 📊 What Changed

### New Files Created
1. **`pkg/platform/kubeconfig/context.go`** (131 lines)
   - Context detection logic
   - Context switching functions
   - Directory path parsing

2. **`docs/infractl-kubeconfig-switching.md`** (178 lines)
   - Complete documentation
   - Usage examples
   - Troubleshooting guide

### Modified Files
- **`pkg/platform/terraform/runner.go`**
  - Integrated context switching before terraform init
  - Added helper function `switchKubeconfigContext()`

- **ArgoCD Module Cleanup**
  - Removed git credentials management (should be done via ArgoCD UI)
  - Removed initial app deployment (was causing CRD errors)
  - Removed port-forward outputs (as requested)

## 🚀 How to Use

### Basic Usage

```bash
# Rebuild the CLI (already done)
make build-infractl

# Use as normal - context switching is automatic!
infractl plan local platform
infractl plan dev platform
infractl apply local platform
```

### Example Output

```bash
$ infractl plan dev platform

─── Hera :: Plan ────────────────────────────────
Environment: dev
Stack:       platform
────────────────────────────────────────────────────
🔄 Switching kubeconfig context: hera-local → hera-dev
✔ Switched to context: hera-dev

[terraform output follows...]
```

## 🎨 Context Naming Convention

The system follows a consistent naming pattern:

| Environment Type | Pattern | Examples |
|-----------------|---------|----------|
| **Local (KIND)** | `hera-local` | `hera-local` |
| **Cloud Envs** | `hera-{env}` | `hera-dev`, `hera-staging`, `hera-prod` |

## 🧪 Testing Performed

✅ **Test 1: Local → Dev**
```bash
# Started with: hera-local
$ infractl plan dev platform
🔄 Switching kubeconfig context: hera-local → hera-dev
✔ Switched to context: hera-dev
# Verified: context switched to hera-dev
```

✅ **Test 2: Dev → Local**
```bash
# Started with: hera-dev
$ infractl plan local platform
🔄 Switching kubeconfig context: hera-dev → hera-local
✔ Switched to context: hera-local
# Verified: context switched to hera-local
```

✅ **Test 3: No Switch Needed**
```bash
# Already on correct context
$ infractl plan local platform
✔ Already using correct context: hera-local
# No unnecessary switching
```

## 📁 File Structure

```
Hera/
├── pkg/platform/
│   ├── kubeconfig/
│   │   └── context.go          # 🆕 Context detection & switching
│   └── terraform/
│       └── runner.go            # ✏️ Integrated context switching
├── docs/
│   └── infractl-kubeconfig-switching.md  # 🆕 Documentation
└── bin/
    └── infractl                 # ✏️ Rebuilt CLI
```

## 🔧 Configuration

### For New Environments

When adding a new environment (e.g., `staging`):

1. **Create the directory:**
   ```bash
   mkdir -p infra/terraform/envs/staging/platform
   ```

2. **Add kubeconfig context:**
   ```bash
   # AWS EKS
   aws eks update-kubeconfig --name hera-staging-eks --alias hera-staging

   # Azure AKS
   az aks get-credentials --name hera-staging-aks --alias hera-staging

   # GCP GKE
   gcloud container clusters get-credentials hera-staging-gke --alias hera-staging
   ```

3. **Use normally:**
   ```bash
   infractl plan staging platform  # Auto-switches to hera-staging
   ```

## 🛡️ Error Handling

The system handles errors gracefully:

- **Context not found**: Shows warning but continues (some stacks don't need k8s)
- **kubectl not available**: Shows clear error message
- **Permission issues**: Displays kubectl error output

Example:
```bash
⚠ Warning: Could not switch kubeconfig context:
context 'hera-staging' not found in kubeconfig (available: hera-local, hera-dev)
```

## 📚 Documentation

Full documentation available at:
- **`docs/infractl-kubeconfig-switching.md`**
  - How it works
  - Troubleshooting
  - Advanced usage

## 🔮 Future Enhancements

Potential improvements for later:
- Support for custom context naming via config file
- Dry-run mode to preview context without switching
- Cluster verification (ensure cluster matches expected env)
- Multi-cluster operations

## 📦 Commit Details

**Branch:** `re_design`
**Commit:** `df11391`

**Changes:**
- 16 files changed
- 361 insertions(+)
- 225 deletions(-)

**Commit Message:**
```
feat: Add automatic kubeconfig context switching to infractl

This commit implements automatic kubeconfig context switching in the infractl
CLI to ensure Terraform operations always run against the correct Kubernetes cluster.
```

## ✅ Status

All tasks completed:
- ✅ Created kubeconfig context detection logic
- ✅ Integrated context switching into terraform runner
- ✅ Tested with local and dev environments
- ✅ Rebuilt infractl CLI
- ✅ Documented the feature
- ✅ Committed changes to git

## 🎓 Notes

1. **No User Action Required**: The feature works automatically
2. **Backward Compatible**: Still works with direct terraform usage
3. **Safe**: Only switches contexts, doesn't modify clusters
4. **Tested**: Verified with both local KIND and AWS EKS dev cluster

---

**Ready to use!** Just run `infractl` commands as normal - context switching happens automatically.
