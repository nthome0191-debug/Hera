locals {
  worker_nodes_flat = flatten([
    for group in var.worker_groups : [
      for i in range(group.count) : {
        labels = group.labels
      }
    ]
  ])
}


resource "kind_cluster" "main" {
  name            = var.cluster_name
  wait_for_ready  = true
  kubeconfig_path = pathexpand(var.kubeconfig_path)

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Port mappings for ingress
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }

      # Port mapping for service access (e.g., ArgoCD)
      extra_port_mappings {
        container_port = 30080
        host_port      = 8080
        protocol       = "TCP"
      }
    }

    # Worker nodes
    dynamic "node" {
      for_each = local.worker_nodes_flat
      content {
        role = "worker"
        kubeadm_config_patches = [
          yamlencode({
            kind = "JoinConfiguration"
            nodeRegistration = {
              kubeletExtraArgs = {
                node-labels = join(
                  ",",
                  [for k, v in node.value.labels : "${k}=${v}"]
                  
                )
              }
            }
          })
        ]
      }
    }
  }
}
