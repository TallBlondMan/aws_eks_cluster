# Terraform code for deploying EKS cluster

Use to deploy cluster quickly and securly

Made based on outputs of [Hashicorp tourtorial](https://github.com/hashicorp/learn-terraform-provision-eks-cluster/tree/main)

It includes all necessary IAM roles and policies for EKS and VPC-CNI addon  
Also includes an [autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md) with the neccesary role with policies for autodiscovering the node groups  

Now also includes AWS Load Balancer with Helm provider to deploy it