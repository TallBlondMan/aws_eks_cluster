variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "EKS-Network"
}

variable "vpc_cidr" {
    description = "CIDR of the VPC to be created"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnets" {
    description = "Number of public subnets to create"
    type = number
    default = 2
}

variable "private_subnets" {
    description = "Number of private subnets to create"
    type = number
    default = 2
}

variable "nat_gw_name" {
    description = "Name for NAT Gateway"
    type = string 
    default = "NATGateway-EKS"
}

variable "eip_name" {
    description = "Name for NAT Gateway"
    type = string 
    default = "ElasticIP-EKS"
}

variable "igw_name" {
    description = "Name for NAT Gateway"
    type = string 
    default = "InternetGateway-EKS"
}


