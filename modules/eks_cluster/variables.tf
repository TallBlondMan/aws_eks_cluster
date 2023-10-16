variable "main_region" {
  description = "Region in which the cluster with vpc should be deployed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
    description = "ID of the vpc in which the cluster is to be deployed"
    type = string
    default = ""
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

variable "node_group_instance_types" {
  type    = list(any)
  default = []
}

variable "cluster_subnets_id" {
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