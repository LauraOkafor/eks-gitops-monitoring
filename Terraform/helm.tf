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
  create_duration = "90s"
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "58.3.0"
  timeout    = 600

  depends_on = [null_resource.ensure_namespace, time_sleep.wait_for_cluster]
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

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"
}

resource "helm_release" "flux_source_controller" {
  name       = "source-controller"
  namespace  = "flux-system"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "source-controller"
  version    = "0.41.2" # Use latest stable
}