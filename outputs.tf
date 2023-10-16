output "endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "eks_autoscaler_arn" {
  value       = module.eks_cluster.cluster_autoscaler_arn
  description = "For use in K8s yml"
}