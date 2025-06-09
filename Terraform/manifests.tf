resource "kubectl_manifest" "argocd_application_taskflow" {
  yaml_body = file("${path.module}/../argocd-apps/taskflow/taskflow-app.yaml")
  depends_on = [helm_release.argocd, null_resource.update_kubeconfig, time_sleep.wait_after_kubeconfig]
}