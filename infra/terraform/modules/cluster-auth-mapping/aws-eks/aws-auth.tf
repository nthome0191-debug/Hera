# ==============================================================================
# aws-auth ConfigMap Management (EKS-Specific)
# ==============================================================================
# This ConfigMap is critical for EKS authentication.
# It maps IAM users/roles to Kubernetes users and groups.
# IMPORTANT: Must preserve the node role mapping to prevent cluster breakage!
# ==============================================================================

locals {
  map_users = yamlencode([
    for mapping in local.user_mappings_final : {
      userarn  = mapping.userarn
      username = mapping.username
      groups   = mapping.groups
    }
  ])

  map_roles = yamlencode([
    {
      rolearn  = data.aws_iam_role.node_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }
  ])
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = local.map_users
    mapRoles = local.map_roles
  }

  force = true
}
