#       - NODEGROUP - 
/*==========================
# 8443 - Cluster API to node
# 1025-65535
# 6443 - Cluster API to node
# 53 - CoreDNS
# 4443 - Cluster API to node
# 9443 - Cluster API to node
# 443 - HTTPS
# 10250 /tcp - Kublet API
# 53/udp  - CoreDNS UDP
# ==========================*/
locals {
  security_rules_nodes = {
    ingress_node_api = {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet API"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_node_service = {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      description = "NodePort Services"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_coredns_tcp = {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "CoreDNS service TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_coredns_udp = {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "CoreDNS servce UDP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# Security group for Nodes
resource "aws_security_group" "eks_node_group_sg" {
  name        = "defaultNodeGroup"
  description = "Allowed ports for node group"
  vpc_id      = module.eks_vpc.vpc_id

  dynamic "ingress" {
    for_each = merge(
      local.security_rules_nodes,
      var.eks_node_group_additional_sg_ingress
    )

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow All"
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
    aws_security_group.eks_node_group_sg.id,
  ]
}

# EKS cluster node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eksNodeGroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]

  launch_template {
    id      = aws_launch_template.eks_nodes_template.id
    version = aws_launch_template.eks_nodes_template.latest_version
  }

  subnet_ids = module.eks_vpc.private_subnets[*].id

  # desired_size has to be between min and max
  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    tag = "k8s.io/cluster-autoscaler/enabled"
    tag = "k8s.io/cluster-autoscaler/eks_cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_registry_access,
    aws_iam_role_policy_attachment.node_CNI_policy,
  ]
}