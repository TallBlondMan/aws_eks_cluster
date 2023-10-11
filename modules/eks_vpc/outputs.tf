output "subnet_public_1a" {
  value       = aws_subnet.public_subnet_1a
  description = "description"
  depends_on  = [aws_subnet.public_subnet_1a]
}

output "subnet_public_1b" {
  value       = aws_subnet.public_subnet_1b
  description = "description"
  depends_on  = [aws_subnet.public_subnet_1b]
}

output "subnet_private_1a" {
  value       = aws_subnet.private_subnet_1a
  description = "description"
  depends_on  = [aws_subnet.private_subnet_1a]
}

output "subnet_private_1b" {
  value       = aws_subnet.private_subnet_1b
  description = "description"
  depends_on  = [aws_subnet.private_subnet_1b]
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
  description = "VPC ID for use"
  depends_on = [aws_vpc.eks_vpc]
}

/* output "subnet_list" {
  value = concat(output.subnet_public_1a)
} */