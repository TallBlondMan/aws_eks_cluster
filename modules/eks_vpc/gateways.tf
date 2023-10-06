# Gateway for the VPC
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "GatewayEKS"
  }
}

# Elastic IP for internet access
resource "aws_eip" "eks_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT EIP"
  }
}

# Internet for Cluster
resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "EKS GW NAT"
  }

  depends_on = [
    aws_internet_gateway.eks_igw
  ]
}