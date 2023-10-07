#TODO
# - VPC 
#  - security groups - ports 
#     - EKS cluster 443
#     - NODEGROUP - 8443 1025-65535 6443 53 4443 9443 443 10250 /tcp 53/udp 
# - Add-Ons
#  - CoreDNS
#   - settings
#  - kube-proxy
#   - settings
#  - Amazon NPC CNI
#   - settings
#  - ???
#  - Configure nodes
#   - group nodes
#  - And all the rest goodies

#  Ports for network tcp 22, 943, 945, 443 udp 1194 - for VPN server(OpenVPN)
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
}