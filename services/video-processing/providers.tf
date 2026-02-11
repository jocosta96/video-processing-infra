terraform {
  required_version = ">= 1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    #    kubernetes = {
    #      source  = "hashicorp/kubernetes"
    #      version = "2.36.0"
    #    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }

}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.name
}

provider "time" {}