# Hera Local Development Environment

This directory contains Terraform configurations for running Hera on a local kind (Kubernetes in Docker) cluster.

## Prerequisites

1. **Docker Desktop** - Must be running
   ```bash
   docker --version
   ```

2. **kind** - Kubernetes in Docker
   ```bash
   # Install on macOS
   brew install kind

   # Verify installation
   kind --version
   ```

3. **kubectl** - Kubernetes CLI
   ```bash
   # Install on macOS
   brew install kubectl

   # Verify installation
   kubectl version --client
   ```

4. **Terraform** - Already installed (>= 1.6.0)
   ```bash
   terraform --version
   ```

## Directory Structure

```
local/
├── cluster/    # Creates the kind cluster
├── platform/   # Deploys ArgoCD on the cluster
└── README.md   # This file
```

## Quick Start

### 1. Create the kind Cluster

```bash
cd cluster
terraform init
terraform apply
```

This will:
- Create a kind cluster named `hera-local`
- Configure 1 control-plane node and 2 worker nodes
- Map ports 80, 443, and 8080 to your localhost
- Update your `~/.kube/config` with cluster credentials

Verify the cluster:
```bash
kubectl cluster-info --context hera-local
kubectl get nodes
```

### 2. Deploy the Platform (ArgoCD)

```bash
cd ../platform
terraform init
terraform apply
```

This will:
- Deploy ArgoCD to the `argocd` namespace
- Generate a random admin password
- Configure git repository credentials (if provided)

### 3. Access ArgoCD UI

Get the admin password:
```bash
terraform output -raw argocd_admin_password
```

Port-forward to ArgoCD server:
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

Access the UI:
- URL: https://localhost:8080
- Username: `admin`
- Password: (from terraform output above)

## Configuration

### Cluster Configuration

Edit `cluster/terraform.tfvars` to customize:
- `cluster_name` - Name of the kind cluster (default: `hera-local`)
- `worker_nodes` - Number of worker nodes (default: `2`)
- `kubeconfig_path` - Where to write kubeconfig (default: `~/.kube/config`)

### Platform Configuration

Edit `platform/terraform.tfvars` to customize:
- `argocd_admin_password` - Set a custom password (leave empty for auto-generated)
- `argocd_chart_version` - Specify ArgoCD Helm chart version
- `git_repository_url` - Your GitOps repository URL
- `git_repository_username` - Git username
- `git_repository_password` - Git token/password

## Common Operations

### Check Cluster Status
```bash
kind get clusters
kubectl get nodes
kubectl get pods -A
```

### Delete Everything
```bash
# Destroy platform first
cd platform
terraform destroy

# Then destroy cluster
cd ../cluster
terraform destroy

# Or use kind directly
kind delete cluster --name hera-local
```

### Restart from Scratch
```bash
# Delete cluster
kind delete cluster --name hera-local

# Recreate
cd cluster
terraform apply

# Redeploy platform
cd ../platform
terraform apply
```

### View Logs
```bash
# ArgoCD server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=100 -f

# All ArgoCD pods
kubectl logs -n argocd --all-containers=true --tail=100 -f
```

## Troubleshooting

### Issue: Docker not running
**Error:** `Cannot connect to the Docker daemon`

**Solution:** Start Docker Desktop

### Issue: Port already in use
**Error:** `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Solution:**
- Change the port mapping in `cluster/main.tf`
- Or stop the process using that port

### Issue: Kubeconfig conflicts
**Error:** Context already exists

**Solution:**
```bash
# Backup existing config
cp ~/.kube/config ~/.kube/config.backup

# Or use a different kubeconfig path
export KUBECONFIG=~/.kube/config-hera-local
```

### Issue: ArgoCD not accessible
**Solution:**
```bash
# Check ArgoCD pods are running
kubectl get pods -n argocd

# Check service
kubectl get svc -n argocd

# Port-forward manually
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

## Development Workflow

1. **Code locally** - Make changes to your application
2. **Test on kind** - Deploy via ArgoCD on local cluster
3. **Verify** - Test your changes
4. **Push to git** - Commit and push
5. **Deploy to dev** - Let ArgoCD sync to dev environment

## Differences from Cloud Environments

| Feature | Local (kind) | Cloud (AWS/Azure/GCP) |
|---------|--------------|------------------------|
| Provider | kind | EKS/AKS/GKE |
| Networking | Docker bridge | VPC/VNet |
| Storage | hostPath | EBS/Disk/PD |
| Load Balancer | NodePort/HostPort | Cloud LB |
| Cost | Free | $$$ |
| Performance | Limited by laptop | Scalable |

## Next Steps

After setting up the local environment:

1. **Configure Git Repository** - Update `platform/terraform.tfvars` with your GitOps repo
2. **Deploy Applications** - Use ArgoCD to deploy your apps
3. **Test Changes** - Validate before deploying to cloud
4. **Scale Up** - When ready, deploy to `dev`, `staging`, or `prod`

## Cleanup

To completely remove the local environment:

```bash
# Step 1: Destroy platform
cd platform
terraform destroy -auto-approve

# Step 2: Destroy cluster
cd ../cluster
terraform destroy -auto-approve

# Step 3: Verify
kind get clusters  # Should show no clusters
docker ps  # Should show no kind containers
```

## Tips

- **Save resources** - Delete the cluster when not in use
- **Fast iteration** - Use `kubectl apply` for quick tests, Terraform for infrastructure
- **Multiple clusters** - Change `cluster_name` to run multiple local environments
- **Share configs** - Check in `terraform.tfvars` (without secrets) for team consistency
