# AWS EKS Cluster Module
# TODO: Implement EKS cluster, node groups, IAM roles, security groups
#
# Resources to create:
# - aws_eks_cluster
# - aws_eks_node_group
# - aws_iam_role (cluster and node roles)
# - aws_iam_role_policy_attachment
# - aws_iam_openid_connect_provider (for IRSA)
# - aws_security_group (cluster and node)
# - aws_security_group_rule
# - aws_cloudwatch_log_group
# - aws_eks_addon (vpc-cni, kube-proxy, coredns, ebs-csi-driver)
# - aws_launch_template (for node groups)
