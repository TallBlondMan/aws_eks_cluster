output "endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "eks_autoscaler_arn" {
  value       = module.eks_cluster.cluster_autoscaler_arn
  description = "For use in K8s yml"
}

output "lb_role_arn" {
  value       = module.eks_cluster.aws_load_balancer_controller_role_arn
  description = "For use in later LB deployment"
}

output "cluster_ca" {
  value       = module.eks_cluster.cluster_ca_cert
  description = "For use in Helm provider"
}

output "cluster_name" {
  value       = module.eks_cluster.cluster_name
  description = "ID of the cluster, for use in Helm provider"
}

output "main_region" {
  value = var.main_region
   description = "Region of EKS deployment"
}

output "autoscaler_serviceaccount_name" {
  value = module.eks_cluster.autoscaler_serviceaccount_name
  description = "Name of service account of Autoscaler"
}

output "load_balancer_serviceaccount_name" {
  value = module.eks_cluster.load_balancer_serviceaccount_name
  description = "Name of service account of Load Balancer Controler"
}