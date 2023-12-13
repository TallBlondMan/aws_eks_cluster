variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "EKS-Network"
}

variable "vpc_ip" {
  description = "Brodcast IP of the new VPC"
  type        = string
  default     = "10.0.0.0"
}

variable "vpc_mask" {
  description = "Subnet mask of the whole vpc"
  type        = number
  default     = 16
}

variable "eks_cluster_name" {
  description = "Name of EKS cluster for correct tags on subnets"
  type = string
  default = ""
}

variable "public_subnets" {
  description = "Number of public subnets to create and it's mask"
  type        = map(any)
  default = {
    number = 2,
    mask   = 24
  }
}

variable "private_subnets" {
  description = "Number of private subnets to create and it's mask"
  type        = map(any)
  default = {
    number = 2,
    mask   = 24
  }
}

variable "nat_gw_name" {
  description = "Name for NAT Gateway"
  type        = string
  default     = "NATGateway-EKS"
}

variable "eip_name" {
  description = "Name for NAT Gateway"
  type        = string
  default     = "ElasticIP-EKS"
}

variable "igw_name" {
  description = "Name for NAT Gateway"
  type        = string
  default     = "InternetGateway-EKS"
}


