output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_autoscaler_arn" {
  value       = aws_iam_role.eks_cluster_autoscaler.arn
  description = "For use in K8s yml"
}

output "aws_load_balancer_controller_role_arn" {
  value       = aws_iam_role.aws_load_balancer_controller.arn
  description = "The arn of role for later use in ALB deployment"
}

output "cluster_ca_cert" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "CA of cluster for use in Helm provider"
}

output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.id
  description = "ID of the cluster, later used in HELM provider"
}