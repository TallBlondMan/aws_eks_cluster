variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "eks_cluster_additional_sg_ingress" {
  description = "All the additional sg ingress rules that will go with cluster"
  type = map
  default = {}
}

variable "eks_node_group_additional_sg_ingress" {
  description = "All the additional sg ingress rules that will go with node groupsr"
  type = map
  default = {}
}

variable "eks_addons" {
  description = "Names for addons to be included in cluster"
  type = map
  default = {}
}