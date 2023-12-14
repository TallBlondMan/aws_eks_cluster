variable "main_region" {
  description = "Region in which the cluster with vpc should be deployed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the vpc in which the cluster is to be deployed"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name for the cluster"
  type        = string
  default     = "eks-cluster"
}

variable "node_group_name" {
  type    = string
  default = ""
}

variable "node_group_ami" {
  type    = string
  default = ""
}

variable "node_subnets_ids" {
  description = "IDs of all the subnets in which node group is to reside"
  type        = list(any)
  default     = []
}

variable "node_group_instance_types" {
  type    = list(any)
  default = []
}

variable "node_desired_size" {
  description = "Number of nodes cluster will start with"
  type        = number
  default     = 0
}

variable "node_max_size" {
  description = "Maximal number of nodes cluster can deploy"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimal number of running nodes that cluster can't go below"
  type        = number
  default     = 0
}

variable "node_update_unavailable" {
  description = "Maximal number of nodes that can be down for updates rollout"
  type        = number
  default     = 1
}

variable "node_group_tags" {
  description = "Tags to add to node group"
  type        = map(any)
  default     = {}
}

variable "cluster_subnets_ids" {
  type    = list(any)
  default = []
}

variable "cluster_sg_rules" {
  type    = list(any)
  default = []
}

variable "cluster_additional_sg_rules" {
  description = "All the additional sg ingress rules that will go with cluster"
  type        = map(any)
  default     = {}
}

variable "node_group_additional_sg_rules" {
  description = "All the additional sg ingress rules that will go with node groupsr"
  type        = map(any)
  default     = {}
}

variable "eks_addons" {
  description = "Names for addons to be included in cluster"
  type        = map(any)
  default     = {}
}

variable "eks_node_groups" {
  description = "Details for EKS managed node groups to create"
  type        = map(any)
  default     = {}
}

variable "autoscaler_serviceaccount_name" {
  description = "Name of service account of Autoscaler"
  type        = string
  default     = "cluster-autoscaler"
}

variable "load_balancer_serviceaccount_name" {
  description = "Name of service account of Load Balancer Controler"
  type        = string
  default     = "aws-load-balancer"
}