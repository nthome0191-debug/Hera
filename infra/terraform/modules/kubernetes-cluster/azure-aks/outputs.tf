# TODO: Define outputs matching the interface contract in parent README.md
# Required outputs:
# - cluster_id
# - cluster_endpoint (kube_config.0.host)
# - cluster_ca_certificate
# - cluster_security_group_id (network_profile.0.network_security_group_id)
# - node_security_group_id
# - kubeconfig
# - oidc_provider_arn (oidc_issuer_url in AKS)
#
# AKS-specific outputs:
# - identity_principal_id
# - kubelet_identity_object_id
# - node_pool_ids
