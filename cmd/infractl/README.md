# Hera - Infractl CLI

`infractl` is the command-line tool for managing Hera’s infrastructure stacks.
It provides a simple, uniform interface for applying, destroying, planning, and inspecting Terraform environments across AWS, Azure, and GCP.

The CLI is filesystem-driven, supports hybrid positional + flags, and automatically detects the Hera repository root, so you can run it from anywhere inside the repo.

---

# 🚀 Features

- Multi-env ready (dev, staging, prod)
- Multi-cloud ready (AWS, Azure, GCP)
- Auto-detects repository root
- Automatic Terraform path resolution
- Hybrid command syntax (positional arguments and flags)

# 🧩 Command Resolution Logic

When you run:

infractl apply <env> <stack> [cloud]

The CLI resolves Terraform path in this order:
```
1. infra/terraform/envs/<env>/<cloud>/<stack>
2. infra/terraform/envs/<env>/<stack>
```
If neither exists → error.

## Examples
```
infractl plan bootstrap aws
infractl apply dev cluster aws
infractl apply dev platform
```
---

# 🔧 Installation

From repo root:

make infractl

# 🚀 Deployment Order Instructions

To ensure a stable, consistent, and functional infrastructure environment, always follow this deployment order:

## 1️⃣ Deploy **Bootstrap** first
Bootstrap configures:
- Remote state (S3 / GCS / Azure)
- State locking (DynamoDB / Cosmos / Firestore)
- Backend configuration
- Any foundational persistent infra

Command example:
```
infractl apply bootstrap aws
```

## 2️⃣ Deploy **Cluster** after Bootstrap
Cluster provisioning depends on the backend created by bootstrap.

Command example:
```
infractl apply dev cluster aws
```

## 3️⃣ Deploy **Platform** last
Platform depends on a running Kubernetes cluster and remote-state outputs.

Command example:
```
infractl apply dev platform
```

# ✅ Summary

```
bootstrap  →  cluster  →  platform
```

Bootstrap must exist before cluster.  
Cluster must exist before platform.  
Platform should be destroyed before cluster, and cluster before bootstrap in order to avoid orphan hanging resources (that can create conflicts and footprint on monthly billing).