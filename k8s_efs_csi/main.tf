resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-efs-csi-controler"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = "2.5.2"

  set {
    name  = "controller.serviceAccount.name"
    value = data.terraform_remote_state.k8s_cluster.outputs.efs_csi_serviceaccount_name
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.terraform_remote_state.k8s_cluster.outputs.efs_csi_role_arn
  }
}