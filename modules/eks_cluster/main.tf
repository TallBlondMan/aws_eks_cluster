########################################################
#                       Cluster
########################################################
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.cluster_subnets_id

    security_group_ids = [
      aws_security_group.eks_cluster_sg.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_cluster_resource_policy,
  ]
}


resource "aws_eks_addon" "eks_cni" { # TODO
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_iam_role_policy_attachment.eks_cni_policy
  ]
}

########################################################
#                   Security Groups
########################################################
locals {
  security_rules_nodes = {
    ingress_node_api = {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet API"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_node_service = {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      description = "NodePort Services"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_coredns_tcp = {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "CoreDNS service TCP"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_coredns_udp = {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "CoreDNS servce UDP"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    egress_cluster_allow_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow All"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }
  security_rules_cluster = {
    ingress_cluster_api_node = {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet API"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_cluster_api_server = {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "Kubernetes API server"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_cluster_https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Kubelet API"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_cluster_etcd = {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      description = "etcd server client API"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_cluster_schedule = {
      from_port   = 10259
      to_port     = 10259
      protocol    = "tcp"
      description = "kube-scheduler"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_cluster_manager = {
      from_port   = 10257
      to_port     = 10257
      protocol    = "tcp"
      description = "kube-controller-manager"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    egress_cluster_allow_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow All"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "ClusterSecurityGroup"
  description = "Allowed ports for cluster"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = merge(
      { for k, v in local.security_rules_cluster : k => v if v.type == "ingress"},
      { for k, v in var.cluster_additional_sg_rules : k => v if v.type == "ingress"},
    )

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" { #TODO
    for_each = merge(
      { for k, v in local.security_rules_cluster : k => v if v.type == "egress"},
      { for k, v in var.cluster_additional_sg_rules : k => v if v.type == "egress"},
    )
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      description = egress.value.description
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

resource "aws_security_group" "eks_node_group_sg" {
  name        = "defaultNodeGroup"
  description = "Allowed ports for node group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = merge(
      { for k, v in local.security_rules_nodes : k => v if v.type == "ingress"},
      { for k, v in var.node_group_additional_sg_rules : k => v if v.type == "ingress"},
    )

    content { #TODO
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = merge(
      { for k, v in local.security_rules_nodes : k => v if v.type == "egress"},
      { for k, v in var.node_group_additional_sg_rules : k => v if v.type == "egress"},
    )

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      description = egress.value.description
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

########################################################
#                   Node Groups
########################################################
resource "aws_launch_template" "eks_nodes_template" { #TODO
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

resource "aws_eks_node_group" "eks_node_group" { #TODO
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn

  ami_type       = var.node_group_ami
  instance_types = var.node_group_instance_type

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

########################################################
#                       IAM 
########################################################

resource "aws_iam_role" "eks_cluster_role" {
  name = "ClusterServiceRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_cluster_resource_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}


resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eksNodeGroupRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
# Policies for Node group as per https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_registry_access" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "node_CNI_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


data "tls_certificate" "eks_tls" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# The account should be created on it's own https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
data "aws_iam_policy_document" "eks_oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_vpc_cni_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_policy.json
  name               = "eksVPCCNIRole"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_vpc_cni_role.name
}
####################################################################
#                       AUTOSCALER
####################################################################

data "aws_iam_policy_document" "eks_oidc_policy_node" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "node_access_autoscaling" {
  name = "eksNodeAutoscalerAccess"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

resource "aws_iam_role" "eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_policy_node.json
  name               = "EKSClusterAutoscaler"
}
resource "aws_iam_role_policy_attachment" "node_access_autoscaling" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.node_access_autoscaling.arn
}