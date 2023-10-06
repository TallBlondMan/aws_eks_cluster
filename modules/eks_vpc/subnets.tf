# 4 required subnets for EKS cluster - 2 public, 2 private 
# As per https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                = "public-us-east-1a"
    "kubernetes.io/cluster/eks_cluster" = "shared"
    "kubernetes.io/role/elb"            = 1
  }
}
resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                = "public-us-east-1b"
    "kubernetes.io/cluster/eks_cluster" = "shared"
    "kubernetes.io/role/elb"            = 1
  }
}
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name                                = "private-us-east-1a"
    "kubernetes.io/cluster/eks_cluster" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
}
resource "aws_subnet" "private_subnet_1b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                                = "private-us-east-1b"
    "kubernetes.io/cluster/eks_cluster" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
}