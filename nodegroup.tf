# EKS cluster node groups
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eksNodeGroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids = [
    module.eks_vpc.subnet_public_1a.id,
    module.eks_vpc.subnet_public_1b.id,
    module.eks_vpc.subnet_private_1a.id,
    module.eks_vpc.subnet_private_1b.id,
  ]

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_registry_access,
    aws_iam_role_policy_attachment.node_CNI_policy,
  ]
}