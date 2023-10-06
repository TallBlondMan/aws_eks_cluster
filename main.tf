#TODO
# - iam role for K8s
#  - EKS-Cluster role
#  - trusted entities
#  - policy
# - VPC 
#  - subnets 
#  - security groups - ports?
#  - cluster IP address family?
#  - cluster enpoint access - private
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
  name = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      module.subnet_public_1a.id
      module.subnet_public_1b.id
      module.subnet_private_1a.id
      module.subnet_private_1b.id
    ]
  }

  depends_on = [
    aws_ia
  ]
}