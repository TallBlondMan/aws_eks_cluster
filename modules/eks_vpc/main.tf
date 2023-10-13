data "aws_availability_zones" "available" {
  state = "available"
}

# VPC used by eks
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

####################################
#         Subnets
####################################

resource "aws_subnet" "private" {
  count = var.private_subnets

  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name                                = "private-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/eks_cluster" = "owned"
    "kubernetes.io/role/internal-elb"   = 1
  }
}

resource "aws_subnet" "public" {
  count = var.public_subnets

  cidr_block = cidrsubnet(var.vpc_cidr, 8, var.public_subnets+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name                                = "public-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/eks_cluster" = "owned"
    "kubernetes.io/role/elb"            = 1
  }
}

####################################
#            Interfaces
####################################

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = var.nat_gw_name
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
    Name = var.igw_name
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
