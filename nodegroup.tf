#     - NODEGROUP - 8443 1025-65535 6443 53 4443 9443 443 10250 /tcp 53/udp 
locals {
  security_groups = {
    ingress_node_api = {
      from_port = 10250
      to_port = 10250
    }
    ingress_node_service = {
      from_port = 30000
      to_port = 32767
    }
  }
}

# Security groups for Nodes
resource "aws_security_group" "eks_node_group_sg" {
  name = "defaultNodeGroup"
  description = "Allowed ports for node group"
  vpc_id = module.eks_vpc.vpc_id

  dynamic "ingress" {
    for_each = local.security_groups

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# Template to assign security groups
resource "aws_launch_template" "eks_nodes_template" {
  name = "eksNodeTemplate"

  block_device_mappings {
    device_name = "/dev/sdb"

    ebs {
      volume_size = 20
    }
  }

  vpc_security_group_ids = [

  ]
}

# EKS cluster node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eksNodeGroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn

  ami_type       = "AL2_x86_64"
  instance_types = ["t2.micro", "t3.small", "t3.medium"]

  launch_template {
    id      = eks_nodes_template.id
    version = eks_nodes_template.latest_version
  }

  subnet_ids = [
    module.eks_vpc.subnet_private_1a.id,
    module.eks_vpc.subnet_private_1b.id,
  ]
  # desired_size has to be between min and max
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_registry_access,
    aws_iam_role_policy_attachment.node_CNI_policy,
  ]
}