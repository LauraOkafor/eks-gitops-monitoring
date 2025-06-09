module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id = aws_vpc.eks-cluster-vpc.id

  create_iam_role                  = true  # Default is true
  attach_cluster_encryption_policy = false # Default is true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  control_plane_subnet_ids = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id,
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]

  create_cluster_security_group      = true
  cluster_security_group_description = "EKS cluster security group"

  bootstrap_self_managed_addons = true

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  dataplane_wait_duration = "40s"

  # some defaults
  enable_security_groups_for_pods = true

  #override defaults
  create_cloudwatch_log_group   = false
  create_kms_key                = false
  enable_kms_key_rotation       = false
  kms_key_enable_default_policy = false
  enable_irsa                   = true
  cluster_encryption_config     = {}
  enable_auto_mode_custom_tags  = false

  # Add EBS CSI Driver addon
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  create_node_security_group                   = true
  node_security_group_enable_recommended_rules = true
  node_security_group_description              = "EKS node group security group - used by nodes to communicate with the cluster API Server"

  node_security_group_use_name_prefix = true

  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  eks_managed_node_groups = {
    # Single node group for all workloads
    default_nodes = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      
      # Add IAM policies for EBS
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      
      # Increase creation timeout
      timeouts = {
        create = "30m"
        update = "30m"
        delete = "30m"
      }
    }
    
    # Node group for system workloads (replacing Fargate)
    system_nodes = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 1
      max_size       = 2
      
      # Add labels for system workloads
      labels = {
        role = "system"
      }
      
      # Add IAM policies for EBS
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }
}