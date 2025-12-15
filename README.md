# Hera

> Cloud-agnostic Kubernetes platform for startups – from zero to cluster with a single command.

Hera is an open-source infrastructure mono-repo that gives you:

- **Network:** VPC/VNet + subnets + routing
- **Kubernetes clusters:** EKS / GKE / AKS / local
- **Platform layer:** GitOps, observability, service mesh, operators
- **CLI:** `infractl` for one-command provisioning

Built on Terraform. Designed for startups. Cloud-agnostic by default.

---

## Why Hera?

### The problem today
Existing IaC/Kubernetes stacks are:

- Cloud-specific
- Complex
- Enterprise-oriented
- Expensive by default

### Hera is different
- **Cloud-agnostic**
- **Developer/SRE friendly**
- **Startup-optimized**
- **GitOps-native**
- **Opinionated but simple**

Hera gives small teams a foundation normally found only in mature platform engineering orgs.

---

## Who Is Hera For?

- Early-stage startups
- Solo DevOps/SREs
- Software consultancies
- Product teams who need infra but don’t want to build it from scratch
- Anyone who values clarity and cost-efficiency

---

## Architecture

### 1. bootstrap/

- Terraform backends (S3/GCS/Azure Storage)
- Minimal IAM requirements

### 2. network/

Cloud modules:

- `network/aws`
- `network/gcp`
- `network/azure`

Outputs:

- Subnet IDs
- Routing/SGs/NSGs
- Network references for cluster layer

### 3. kubernetes-cluster/

Modules:

- `aws-eks`
- `gke`
- `aks`
- `local`

Outputs:

- Cluster endpoint
- CA data
- Auth info
- OIDC/IAM integration hooks

### 4. platform/

Includes:

- ArgoCD GitOps
- Optional Gitea
- Ingress + cert-manager
- Observability (planned)
- **Istio mesh (optional)**
- Operator library

### 5. identity/ (planned)

IAM personas → cloud roles + Kubernetes RBAC.

### 6. cli/ — `infractl`

Example UX:

```
infractl apply --cloud aws --env dev
infractl destroy --cloud gcp --env playground
```

---

## Startup-Friendly Mode

Hera ships with **dev vs prod** modes:

### Dev Mode
- Minimal nodes
- Single-AZ
- NAT-reduced or NAT-less
- Light observability

### Prod Mode
- Multi-AZ
- More IAM boundaries
- Full observability
- Optional policy packs

---

## Security Baseline (Planned)

Includes:

- Private subnets
- Least-privilege IAM
- Pod Security Standards
- Basic audit logging
- Optional Gatekeeper/Kyverno policies
- Secure GitOps defaults

---

## Roadmap

### v0.1 AWS Dev Foundation
- AWS bootstrap, network, EKS
- Basic platform and ArgoCD
- infractl prototype

### v0.2 Policies & Observability
### v0.3 GCP Support
### v0.4 Azure Support
### v0.5 Identity Personas
### v1.0 Multi-cloud stable release

---

## Fork-Friendly Design

This project is designed to be easily customized for your organization. All "Hera" references can be automatically replaced with your project name:

```bash
./scripts/setup-fork.sh
```

This updates:
- Go module name and imports
- Terraform variables and resource names
- Kubernetes RBAC groups and labels
- CLI descriptions
- AWS resource naming patterns

See [docs/FORKING_GUIDE.md](docs/FORKING_GUIDE.md) for complete instructions.

---

## License

TBD (likely Apache-2.0 or MIT)
