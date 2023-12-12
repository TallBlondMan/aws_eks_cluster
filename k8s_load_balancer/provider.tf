provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.k8s_cluster.outputs.endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.k8s_cluster.outputs.cluster_ca) # base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.k8s_cluster.outputs.cluster_name]
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