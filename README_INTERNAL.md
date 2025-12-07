# Hera – Internal Notes & Future Work

> Personal notes for Natali – not part of the public open-source README.

Hera is a cloud-agnostic, startup-friendly infrastructure mono-repo that provides:

- Bootstrap (TF state, locking, initial IAM)
- Network (VPC/VNet + subnets + routing)
- Kubernetes clusters (EKS / GKE / AKS / local)
- Platform layer (GitOps, observability, service mesh, operators)
- A thin CLI (`infractl`) to make all of the above a one-command experience per environment

The long-term goal is:
```
infractl apply --cloud aws --env dev
```
→ You get a fully working, cost-aware, secure-enough Kubernetes platform, using Terraform under the hood.

---

## 1. Research: Existing Community Building Blocks

### 1.1 AWS

Target: Compare Hera’s AWS modules to:

- **EKS Blueprints (Terraform)**
- **terraform-aws-modules/eks**
- **terraform-aws-modules/vpc**

Checklist:

- [ ] Compare VPC structures
- [ ] Compare node group patterns
- [ ] Compare IAM/IRSA wiring
- [ ] Compare add-ons and their approach
- [ ] Identify which patterns Hera should replicate or avoid

---

### 1.2 GCP

Modules to compare:

- **terraform-google-kubernetes-engine**
- **Google VPC modules**

Checklist:

- [ ] Private GKE reference architecture
- [ ] Node pool defaults
- [ ] IAM/service accounts
- [ ] Logging/monitoring integrations

---

### 1.3 Azure

Modules to compare:

- **AKS Landing Zone Accelerator**
- **CAF Terraform**

Checklist:

- [ ] Minimal hub/spoke considerations
- [ ] Recommended RBAC policies
- [ ] Network defaults suitable for startups
- [ ] Mapping complexity → startup simplicity

---

## 2. Hera Architecture (Internal)

### Layers

1. **bootstrap/**
2. **network/**
3. **kubernetes-cluster/**
4. **platform/**
5. **identity/**
6. **cli/** – `infractl`

### Common Contracts

- Inputs/outputs identical across clouds
- CI-friendly
- GitOps-ready

---

## 3. Security & Policies

Target: Minimal CISO-approved baseline:

- Private networking
- Least-privilege IAM defaults
- Pod Security Standards
- Restricted ingress
- Basic audit logging
- Optional policy-pack via OPA/Kyverno

---

## 4. IAM Personas (“New Employee” Module)

Personas:

- Developer
- SRE
- DevOps
- IT/Admin
- CISO

Each persona should map to:

- Cloud-specific IAM (AWS/GCP/Azure)
- Kubernetes RBAC
- GitOps (ArgoCD) roles

---

## 5. Platform Enhancements

Future modules:

- Istio (optional)
- Observability stack
- Operator library:
  - cert-manager
  - external-dns
  - kafka operator
  - DB operators
  - monitoring operators

---

## 6. Roadmap Items

Internal roadmap:

- AWS v1
- GCP v1
- Azure v1
- Local cluster
- IAM personas
- Policy packs
- infractl v1
