terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }

  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "flux_helm_controller" {
  name       = "helm-controller"
  namespace  = "flux-system"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "helm-controller"
  version    = "0.37.0" # Use latest stable

  create_namespace = true
}