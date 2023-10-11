#TODO
# Add autoscaler 
#   - https://karpenter.sh/docs/
#   - https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md 
# Cluster does not remove due to "deleting EKS Cluster (eks_cluster): ResourceInUseException: Cluster has nodegroups attached"
# Names for nodes instances -     aws_launch_template
# Look into template for nodes
#  Ports for VPN server(OpenVPN) tcp 22, 943, 945, 443 |  udp 1194 

# Custom security group for cluster - port 443
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eks_vpc" {
  source = "./modules/eks_vpc"
}

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

# Cluster security group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "ClusterSecurityGroup"
  description = "Allowed ports for cluster"
  vpc_id      = module.eks_vpc.vpc_id

  dynamic "ingress" {
    for_each = local.security_rules_cluster

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
    subnet_ids = [
      module.eks_vpc.subnet_public_1a.id,
      module.eks_vpc.subnet_public_1b.id,
      module.eks_vpc.subnet_private_1a.id,
      module.eks_vpc.subnet_private_1b.id,
    ]

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