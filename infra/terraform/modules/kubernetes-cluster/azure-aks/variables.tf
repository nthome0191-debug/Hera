# TODO: Define input variables matching the interface contract in parent README.md
# Required variables:
# - cluster_name
# - environment
# - region (location in Azure)
# - kubernetes_version
# - vpc_id (vnet_id in Azure)
# - private_subnet_ids
# - public_subnet_ids
# - node_groups (node_pools in AKS)
# - enable_private_endpoint (private_cluster_enabled)
# - enable_public_endpoint
# - authorized_networks (api_server_authorized_ip_ranges)
# - tags
#
# AKS-specific optional variables:
# - network_plugin (default: azure)
# - network_policy (default: azure)
# - enable_workload_identity (default: true)
# - enable_azure_ad_rbac (default: true)
