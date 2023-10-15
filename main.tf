#TODO
# Variablize:
# - add addons names as variable
# - work on launch template, more options like CPU
# - node group:
#   - ami
#   - type
#   - disk size
#   - scalin, update
#   - tags
# - IAM - role attachment and policy creaton ??
# - private public node groups ??
#
# ---Move into one main.tf---
# ---Make it as module??---
# Cluster does not remove due to "deleting EKS Cluster (eks_cluster): ResourceInUseException: Cluster has nodegroups attached"
#  Ports for VPN server(OpenVPN) tcp 22, 943, 945, 443 |  udp 1194 

# Custom security group for cluster - port 443
locals {
  security_rules_cluster = {
    ingress_cluster_api_node = {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet API"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_api_server = {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "Kubernetes API server"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Kubelet API"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_etcd = {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      description = "etcd server client API"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_schedule = {
      from_port   = 10259
      to_port     = 10259
      protocol    = "tcp"
      description = "kube-scheduler"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_manager = {
      from_port   = 10257
      to_port     = 10257
      protocol    = "tcp"
      description = "kube-controller-manager"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "eks_vpc" {
  source = "./modules/eks_vpc"

  vpc_name = "Kubernetes Cluster VPC"
  vpc_ip = "10.6.0.0"
  vpc_mask = 16

  public_subnets = {
    number = 3,
    mask   = 24,
  }
  private_subnets = {
    number = 3,
    mask   = 24,
  }
}

# Cluster security group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "ClusterSecurityGroup"
  description = "Allowed ports for cluster"
  vpc_id      = module.eks_vpc.vpc_id

  dynamic "ingress" {
    for_each = merge(
      local.security_rules_cluster,
      var.eks_cluster_additional_sg_ingress,
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

# THE CLUSTER
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.eks_vpc.all_subnets[*].id

    security_group_ids = [
      aws_security_group.eks_cluster_sg.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_cluster_resource_policy,
  ]
}

# CNI addon for cluster
resource "aws_eks_addon" "eks_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_iam_role_policy_attachment.eks_cni_policy
  ]
}