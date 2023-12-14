resource "helm_release" "eks_autoscaler" {
  name = "eks-autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.34.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = data.terraform_remote_state.k8s_cluster.outputs.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.terraform_remote_state.k8s_cluster.outputs.main_region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = data.terraform_remote_state.k8s_cluster.outputs.autoscaler_serviceaccount_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.terraform_remote_state.k8s_cluster.outputs.eks_autoscaler_arn
  }
}