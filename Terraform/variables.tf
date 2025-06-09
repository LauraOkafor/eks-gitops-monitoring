variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  default     = "eks-cluster"
  description = "EKS cluster name"
}

variable "eks_version" {
  type        = string
  default     = "1.31"
  description = "EKS version"
}

variable "cidr_block" {
  type        = string
  default     = "10.10.0.0/16"
  description = "CIDR block for the VPC"
}

variable "tags" {
  type        = map(string)
  default     = {
    Name = "eks-cluster-vpc"
  }
  description = "Tags for AWS resources"
}

# GitHub variables for Flux
variable "github_owner" {
  type        = string
  description = "GitHub owner/organization for Flux repository"
  default     = "your-github-username"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name for Flux"
  default     = "eks-gitops-monitoring"
}