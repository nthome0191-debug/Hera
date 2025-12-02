# Hera - Multi-Cloud Bootstrap Architecture

Hera's infrastructure is designed to be **cloud-agnostic**, **cost-efficient**, and **easy to recreate**.  
To support this design, the `bootstrap` layer contains only the persistent Terraform backend resources, separated by provider:

```
modules/bootstrap/
├── aws/
├── azure/
└── gcp/
```

Each directory contains a backend-bootstrap module for its provider.

---

# Why Bootstrap is a Separate Module

Most infrastructure stacks (network, Kubernetes cluster, observability stack, CI/CD, services, databases, etc.) can be **created and destroyed freely**.  
However, Terraform itself requires stable backend resources that persist **regardless of the lifecycle of the environment**.

### The bootstrap module solves this by providing:

- **Remote state storage**  
- **State locking**  
- **Provider-specific minimal IAM/security components**  
- **A foundation on which all other stacks depend**

By isolating bootstrap:

### ✔ You reduce cost  
Only the bootstrap stays alive. Everything else can be destroyed and recreated with 1-2 commands.

### ✔ You enable extreme cost-efficiency  
For early-stage startups:

**Destroy dev/staging at end of day → recreate in the morning.**

This can reduce monthly infra cost by **50-60%**.

---

# Provider-Specific Bootstrap Modules

### AWS Bootstrap
Creates S3 backend + DynamoDB locking + optional IAM role.  
Cost: **$0.50 - $1.80 / month**

### Azure Bootstrap (future)
Expected: Storage Account + Blob Container + Table  
Cost: **$1 - $3 / month**

### GCP Bootstrap (future)
Expected: GCS Bucket + Firestore/Datastore lock  
Cost: **$0.40 - $1.50 / month**

---

# Cost Summary Across Clouds

| Cloud | Typical Bootstrap Monthly Cost |
|-------|--------------------------------|
| AWS | **$0.50 - $1.80** |
| Azure | **$1 - $3** |
| GCP | **$0.40 - $1.50** |

---

# Important Note

As long as Hera is running on a particular cloud provider, that provider's bootstrap module **must remain intact**, because it stores the Terraform state required to apply and destroy all other stacks.

Everything else in the system (network, Kubernetes cluster, apps, observability, etc.) can be torn down and rebuilt at will.

