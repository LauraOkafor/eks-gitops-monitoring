resource "kubectl_manifest" "argocd_application_taskflow" {
  yaml_body = file("${path.module}/argocd-apps/taskflow/taskflow-app.yaml")
}