# Hera

Hera is a cloud-agnostic infrastructure mono-repo designed to provision,
manage, and evolve modern Kubernetes platforms across AWS, Azure, and
GCP. It provides a clean, modular Terraform architecture and a
foundation for future platform components such as Argo Workflows,
ArgoCD, BuildKit, and custom Kubernetes operators.

## Vision

Hera is a reusable infrastructure backbone intended for multi-project
use. It enables fast, repeatable creation of ephemeral or long-lived
Kubernetes clusters, supporting development, testing, and production
environments without coupling to any application.

## Key Features

-   Cloud-agnostic, multi-cloud-ready module structure
-   Layered Terraform architecture
-   Clear separation between cloud-specific and common logic
-   App-agnostic, entirely platform-focused
-   Environment-based composition (`envs/dev`, `envs/prod`, etc.)
-   Cost-efficient ephemeral cluster workflow
-   Foundation for future platform components (GitOps, CI, operators)

## Repository Structure

    hera/
      README.md

      infra/
        terraform/
          modules/

            network/
              aws/
              azure/
              gcp/

            kubernetes-cluster/
              aws-eks/
              azure-aks/
              gcp-gke/

            platform/
              base/

          envs/
            dev/
              aws/
                main.tf
                variables.tf
                outputs.tf

            prod/
              aws/

      k8s/
        base/
        overlays/
          dev/
          prod/

      operators/
        redis-operator/
        mongo-operator/
        secrets-operator/

      pkg/
        platform/

      cmd/
        infractl/

      Makefile

## Principles

-   Cloud-specific logic must remain inside cloud-specific module
    directories.
-   Module interfaces (inputs/outputs) must stay consistent across
    clouds.
-   Environments contain only composition logic, never business logic.
-   The project must remain application-agnostic.
-   Terraform resources must support full teardown via
    `terraform destroy`.
-   Future features (ArgoCD, operators, platform services) must
    integrate cleanly.

## Getting Started

1.  Install Terraform and AWS CLI (or Azure/GCP CLI if using other
    clouds).
2.  Configure provider credentials for the cloud you wish to deploy to.
3.  Navigate to the desired environment directory, e.g.:

```{=html}
<!-- -->
```
    cd infra/terraform/envs/dev/aws
    terraform init
    terraform apply

4.  A fully configured Kubernetes cluster will be created.

## Future Plans

-   Add Azure and GCP implementations for network + cluster modules.
-   Introduce Argo Workflows and BuildKit for Kubernetes-native CI.
-   Introduce ArgoCD for GitOps-managed platform components.
-   Add custom operators under `operators/`.
-   Provide CLI tooling under `cmd/infractl`.

------------------------------------------------------------------------

Hera is your foundation for creating consistent, powerful, and
maintainable infrastructure across clouds.
