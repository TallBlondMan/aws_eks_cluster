output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_autoscaler_arn" {
  value       = aws_iam_policy.node_access_autoscaling.arn
  description = "For use in K8s yml"
}