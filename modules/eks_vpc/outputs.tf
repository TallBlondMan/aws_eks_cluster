output "private_subnets" {
  description = "All the private subnets created"
  value = aws_subnet.private
  depends_on = [aws_subnet.private]
}

output "public_subnets" {
  description = "All the public subnets created"
  value = aws_subnet.public
  depends_on = [aws_subnet.public]
}

output "all_subnets" {
  description = "All subnets within VPC"
  value = concat(aws_subnet.private, aws_subnet.public)
  depends_on = [
    aws_subnet.private,
     aws_subnet.public
  ]
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
  description = "VPC ID for use"
  depends_on = [aws_vpc.eks_vpc]
}