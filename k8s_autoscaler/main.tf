resource "helm_release" "eks_autoscaler" {
    name = "eks-autoscaler"

    repository = "https://kubernetes.github.io/autoscaler"
    chart      = "cluster-autoscaler"
    version    = "9.34.0"

    set {
        name = "autoDiscovery.clusterName"
        value = data.terraform_remote_state.k8s_cluster.outputs.cluster_name
    }

    set {
        name = "awsRegion="
        value = data.terraform_remote_state.k8s_cluster.variables.main_region
    }
}