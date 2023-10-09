#TODO
# Names for nodes instances -     aws_launch_template
# Look into template for nodes
# Security group for instances
# Security group for cluster
#     - EKS cluster 443
#  Ports for network tcp 22, 943, 945, 443 udp 1194 - for VPN server(OpenVPN)

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