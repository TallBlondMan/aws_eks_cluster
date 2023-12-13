resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.5.1"

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.k8s_cluster.outputs.cluster_name
  }

  # set {
  #   name  = "serviceAccount.create"
  #   value = "false"
  # }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  # REF: https://github.com/Young-ook/terraform-aws-eks/tree/main/modules/helm-addons 
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.terraform_remote_state.k8s_cluster.outputs.lb_role_arn
  }
}