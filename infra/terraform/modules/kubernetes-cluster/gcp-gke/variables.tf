# TODO: Define input variables matching the interface contract in parent README.md
# Required variables:
# - cluster_name
# - environment
# - region
# - kubernetes_version (min_master_version)
# - vpc_id (network)
# - private_subnet_ids (subnetwork)
# - public_subnet_ids
# - node_groups (node_pools in GKE)
# - enable_private_endpoint (enable_private_endpoint)
# - enable_public_endpoint
# - authorized_networks (master_authorized_networks_config)
# - tags (labels in GCP)
#
# GKE-specific optional variables:
# - enable_workload_identity (default: true)
# - enable_shielded_nodes (default: true)
# - release_channel (default: REGULAR)
# - ip_range_pods (secondary range name)
# - ip_range_services (secondary range name)
