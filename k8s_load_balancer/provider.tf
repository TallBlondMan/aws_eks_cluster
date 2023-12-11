provider "helm" {
  kubernetes {
    host                   = terraform_remote_state.k8s_cluster.endpoint
    cluster_ca_certificate = terraform_remote_state.k8s_cluster.cluster_ca # base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", terraform_remote_state.k8s_cluster.id]
      command     = "aws"
    }
  }
}

data "terraform_remote_state" "k8s_cluster" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}