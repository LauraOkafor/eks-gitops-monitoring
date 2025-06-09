# Use existing namespace or create if it doesn't exist
resource "null_resource" "ensure_namespace" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name} && kubectl get namespace monitoring || kubectl create namespace monitoring"
  }
}

# Wait for the EKS cluster to be fully ready
resource "time_sleep" "wait_for_cluster" {
  depends_on      = [module.eks]
  create_duration = "180s" # Increased from 90s to 180s
}

resource "helm_release" "monitoring" {
  name          = "monitoring"
  repository    = "https://prometheus-community.github.io/helm-charts"
  chart         = "kube-prometheus-stack"
  namespace     = "monitoring"
  version       = "58.3.0"
  timeout       = 2400 # Increased to 40 minutes
  atomic        = false
  wait          = true
  wait_for_jobs = false

  depends_on = [null_resource.ensure_namespace, time_sleep.wait_for_cluster, null_resource.update_kubeconfig, time_sleep.wait_after_kubeconfig]
}

resource "helm_release" "postgresql" {
  name          = "postgresql"
  chart         = "../helm-charts/postgresql"
  namespace     = "monitoring"
  timeout       = 1200
  atomic        = false
  wait          = false
  wait_for_jobs = false

  # Use values file instead of inline values
  values = [
    file("${path.module}/postgresql-values.yaml")
  ]

  # Only disable persistence inline
  set {
    name  = "persistence.enabled"
    value = "false"
  }

  depends_on = [null_resource.create_ebs_sc, null_resource.ensure_namespace, time_sleep.wait_for_cluster]
}



resource "helm_release" "backend" {
  name          = "backend"
  chart         = "../helm-charts/backend"
  namespace     = "monitoring"
  timeout       = 1200
  atomic        = false
  wait          = false # Disable waiting
  wait_for_jobs = false # Disable waiting for jobs

  # Add dependency on PostgreSQL service instead of the Helm release
  set {
    name  = "postgresql.enabled"
    value = "false" # Disable built-in PostgreSQL if your chart has one
  }

  set {
    name  = "postgresql.host"
    value = "postgresql.monitoring.svc.cluster.local" # Use external PostgreSQL
  }

  depends_on = [helm_release.postgresql, null_resource.ensure_namespace]
}

resource "helm_release" "frontend" {
  name      = "frontend"
  chart     = "../helm-charts/frontend"
  namespace = "monitoring"
  timeout   = 600

  depends_on = [helm_release.backend, null_resource.ensure_namespace]
}

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks, time_sleep.wait_for_cluster]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}"
  }
}

# Additional wait after kubeconfig is updated
resource "time_sleep" "wait_after_kubeconfig" {
  depends_on      = [null_resource.update_kubeconfig]
  create_duration = "30s"
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "monitoring"
  create_namespace = false

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  depends_on = [null_resource.update_kubeconfig, time_sleep.wait_after_kubeconfig]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"

  set {
    name  = "args"
    value = "{--kubelet-insecure-tls}"
  }

  set {
    name  = "hostNetwork"
    value = "true"
  }
}

