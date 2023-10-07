# Public access table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "public"
  }
}

# Adding subnets to route tables public
resource "aws_route_table_association" "public_subnet_route_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_subnet_route_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public.id
}

# Private access table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }

  tags = {
    Name = "private"
  }
}

# Adding subnets to route tables private
resource "aws_route_table_association" "private_subnet_route_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_subnet_route_1b" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private.id
}