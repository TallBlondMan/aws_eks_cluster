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

output "efs_csi_role_arn" {
  value       = aws_iam_role.aws_efs_csi.arn
  description = "ARN of CSI IAM role - For use in later EFS CSI driver deployment"
}

output "cluster_ca_cert" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "CA of cluster for use in Helm provider"
}

output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.id
  description = "ID of the cluster, later used in HELM provider"
}

output "autoscaler_serviceaccount_name" {
  value       = var.autoscaler_serviceaccount_name
  description = "Name of service account of Autoscaler"
}

output "load_balancer_serviceaccount_name" {
  value       = var.load_balancer_serviceaccount_name
  description = "Name of service account of Load Balancer Controler"
}

output "efs_csi_serviceaccount_name" {
  value       = var.efs_csi_serviceaccount_name
  description = "Name of the Service Account later used in Helm chart"
}