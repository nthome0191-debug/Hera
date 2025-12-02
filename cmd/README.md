# 🚀 infractl — Hera Infrastructure Orchestration CLI

`infractl` is the official command-line tool for managing Hera’s Terraform infrastructure.  
It provides a unified interface for planning, applying, and destroying infrastructure stacks across multiple clouds and environments.

`infractl` handles:

- Automatic Terraform initialization  
- Correct environment and provider path resolution  
- Safe orchestration of stack dependencies  
- Consistent multi-cloud workflows  
- Reduction of human error  

---

# 📌 Deployment Overview

Hera infrastructure is organized into **independent stacks**:

1. **bootstrap**  
2. **network**  
3. **kubernetes cluster (EKS, GKE, AKS)**  
4. **platform layer**  
5. Application layers (Kustomize)

To ensure safe and predictable Terraform operations, you must always apply the **bootstrap** stack first.

---

# 📦 1. Bootstrap (Must Run First)

The **bootstrap** stack prepares the Terraform backend and global resources required for *all other stacks*.

For AWS this includes:

- S3 bucket for Terraform remote state  
- DynamoDB table for state locking  
- IAM permissions for Terraform  
- Backend configuration files  

Without bootstrap, Terraform cannot operate safely.

### Run bootstrap:

```bash
infractl apply aws bootstrap bootstrap
```

This will:

1. Resolve `infra/terraform/envs/bootstrap/aws/bootstrap`
2. Run `terraform init` behind the scenes
3. Create the backend storage
4. Prepare locking for later stacks

You only need to run bootstrap **once per cloud account/region**.

---

# 🌐 2. Standard Stack Deployment Order

After bootstrap is ready, deploy stacks **in order**:

### 1. Network (VPC, subnets, NAT, endpoints)

```bash
infractl plan aws dev network
infractl apply aws dev network
```

### 2. Kubernetes Cluster (EKS/GKE/AKS)

```bash
infractl plan aws dev eks
infractl apply aws dev eks
```

### 3. Platform Layer

(ingress, DNS, cert-manager, secrets, monitoring)

```bash
infractl plan aws dev platform
infractl apply aws dev platform
```

### 4. All stacks at once

```bash
infractl apply aws dev all --auto-approve
```

This executes:  
**network → eks → platform**

---

# 🔥 3. Command Structure

The structure of every infractl command is:

```
infractl <operation> <provider> <environment> <stack>
```

### Operations:
- `plan`
- `apply`
- `destroy`
- `output`

### Providers:
- `aws`
- `gcp`
- `azure`

### Environments:
- `bootstrap`
- `dev`
- `staging`
- `prod`

### Stacks:
- `bootstrap`
- `network`
- `eks`
- `platform`
- `all`

### Examples:

```
infractl plan aws dev network
infractl apply aws dev eks
infractl destroy aws prod platform
infractl output azure staging network
```

`infractl` **automatically runs `terraform init` for you**, so you don’t need to do it manually.

---

# 🔧 4. Destroying Stacks (Reverse Order)

You must destroy stacks in the opposite order of creation:

### Destroy platform:
```bash
infractl destroy aws dev platform --auto-approve
```

### Destroy EKS:
```bash
infractl destroy aws dev eks --auto-approve
```

### Destroy network:
```bash
infractl destroy aws dev network --auto-approve
```

> Never destroy the network while EKS still exists.

---

# 🗂️ 5. Directory Layout (Reference)

```
infra/terraform
├── modules/               # reusable infrastructure modules
└── envs/
    ├── bootstrap/
    │    └── aws/bootstrap
    ├── dev/
    │    └── aws/{network, eks, platform}
    ├── prod/
         └── aws/{network, eks, platform}
```

Each stack is a **root module**, and infractl runs Terraform inside the correct directory.

---

# 🛠️ 6. Why Use infractl Instead of Terraform Directly?

`infractl` provides:

- Automatic `terraform init`
- Automatic resolution of provider/env/stack paths
- Auto-ordering for multi-stack deployments (`all`)
- Clear, safe, reproducible workflows
- Cross-cloud support (AWS, GCP, Azure)
- Eliminates mistakes (wrong folder, missing init, broken backend)
- CI-friendly / automation-friendly interface  

This is the recommended and supported workflow for Hera.

---

# 📝 7. Example Full Workflow (AWS Dev)

### 1. Prepare backend:
```bash
infractl apply aws bootstrap bootstrap
```

### 2. Create network:
```bash
infractl apply aws dev network
```

### 3. Create EKS cluster:
```bash
infractl apply aws dev eks
```

### 4. Install platform components:
```bash
infractl apply aws dev platform
```

### 5. Destroy environment:
```bash
infractl destroy aws dev platform
infractl destroy aws dev eks
infractl destroy aws dev network
```

---

# ❗ Note on Re-running Bootstrap

Do **not** re-run bootstrap unless:

- Using a new AWS/GCP/Azure account  
- Using a new region  
- Changing S3 bucket / DynamoDB config  
- Changing remote backend structure  

Otherwise, bootstrap should **never** be applied again.

---

# 🎯 Summary

| Step | Stack | Purpose |
|------|--------|---------|
| 1 | **bootstrap** | Terraform backend + lock table |
| 2 | **network** | VPC, subnets, gateways, endpoints |
| 3 | **eks** | Control plane, nodes, IAM roles |
| 4 | **platform** | Ingress, DNS, certs, monitoring |
| 5 | **apps** | Application deployment |
