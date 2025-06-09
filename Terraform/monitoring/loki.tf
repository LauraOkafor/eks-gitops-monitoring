resource "helm_release" "loki" {
  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.41.0"

  values = [file("${path.module}/values/loki-values.yaml")]
}