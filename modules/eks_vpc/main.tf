locals {
  vpc_cidr = format("%s/%d", var.vpc_ip, var.vpc_mask)
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC used by eks
resource "aws_vpc" "eks_vpc" {
  cidr_block = local.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

####################################
#         Subnets
####################################
locals{
  private_subnet_tags = {
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned",
      "kubernetes.io/role/internal-elb"   = 1,
  }
  public_subnet_tags = {
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned",
        "kubernetes.io/role/elb"            = 1,
  }
} 


resource "aws_subnet" "private" {
  count = var.private_subnets.number

  cidr_block        = cidrsubnet(local.vpc_cidr, var.private_subnets.mask - var.vpc_mask, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.eks_vpc.id

  tags = merge(
    { "Name" = "private-${data.aws_availability_zones.available.names[count.index]}" },
    local.private_subnet_tags,
  )
}

resource "aws_subnet" "public" {
  count = var.public_subnets.number

  cidr_block              = cidrsubnet(local.vpc_cidr, var.public_subnets.mask - var.vpc_mask, var.public_subnets.number + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks_vpc.id

  tags = merge(
    { "Name" = "public-${data.aws_availability_zones.available.names[count.index]}" },
    local.public_subnet_tags,
  )
}

####################################
#            Interfaces
####################################

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_eip" "eks_nat_eip" {
  domain = "vpc"

  tags = {
    Name = var.eip_name
  }
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = var.nat_gw_name
  }

  depends_on = [
    aws_internet_gateway.eks_igw
  ]
}

####################################
#            Routes
####################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }

  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
