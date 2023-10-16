output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_autoscaler_arn" {
  value       = aws_iam_role.eks_cluster_autoscaler.arn
  description = "For use in K8s yml"
}