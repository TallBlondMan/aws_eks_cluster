terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
  backend "local" {}
}

provider "aws" {
  region = var.main_region
}