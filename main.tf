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
    ingress_node_api = {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "some port"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
  }
  security_rules_node_group = {
    ingress_allow_ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"    
    }
  }
}
output "the_port" {
  value = { for k, v in local.security_rules_cluster : k => v if v.from_port == 10257 }
}

module "eks_vpc" {
  source = "./modules/eks_vpc"

  vpc_name = "Kubernetes Cluster VPC"
  vpc_ip   = "10.6.0.0"
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

module "eks_cluster" {
  source = "./modules/eks_cluster"

  cluster_name                = "EKS-one"
  cluster_subnets_id          = module.eks_vpc.all_subnets[*].id
  cluster_additional_sg_rules = local.security_rules_cluster
  vpc_id                      = module.eks_vpc.vpc_id

  node_groups = {
    nodeg_1 = {
      node_group_name           = "eksNodeGroup"
      node_group_ami            = "AL2_x86_64"
      node_group_instance_types = ["t2.small", "t3.medium"]

      node_scaling = {
        desired_size = 2
        max_size     = 10
        min_size     = 2
      }

      node_group_additional_sg_rules = local.security_rules_node_group

      tags = merge(

      )
    }
  }
}