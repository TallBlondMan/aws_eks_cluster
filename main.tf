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

module "eks_vpc" {
  source = "./modules/eks_vpc"

  vpc_name = "Kubernetes Cluster VPC"
  vpc_ip   = "10.6.0.0"
  vpc_mask = 16
  # Overwrite [ 10.5.2.1/14, 10.6.0.1 ]
  public_subnets = {
    number = 3,
    mask   = 24,
  #  manual_cidr = []
  }
  private_subnets = {
    number = 3,
    mask   = 24,
  }
}

module "eks_cluster" {
  source = "./modules/eks_cluster"

  cluster_name                = "EKS-one"
  cluster_subnets_ids         = module.eks_vpc.all_subnets[*].id
  cluster_additional_sg_rules = local.security_rules_cluster
  vpc_id                      = module.eks_vpc.vpc_id

  eks_node_groups = {
    node_one = {
      node_group_name           = "eksNodeGroup"
      node_group_ami            = "AL2_x86_64"
      node_group_instance_types = ["t2.small", "t3.medium"]

      node_desired_size       = 2
      node_max_size           = 10
      node_min_size           = 2
      node_update_unavailable = 1

      node_subnets_ids               = module.eks_vpc.private_subnets[*].id
      node_group_additional_sg_rules = local.security_rules_node_group

      node_group_tags = {
        "tag" = "first one"
      }
    }
    /* node_two = {
      node_group_name           = "new-node-group"
      node_group_ami            = "AL2_x86_64"
      node_group_instance_types = ["t2.small"]

      node_desired_size       = 1
      node_max_size           = 5
      node_min_size           = 1
      node_update_unavailable = 1

      node_subnets_ids               = module.eks_vpc.private_subnets[*].id
      node_group_additional_sg_rules = local.security_rules_node_group

      node_group_tags = {
        "tag" = "second one"
      }
    } */
  }
}