# Create EBS CSI Driver storage class
resource "null_resource" "create_ebs_sc" {
  depends_on = [module.eks, time_sleep.wait_for_cluster]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: storage.k8s.io/v1
      kind: StorageClass
      metadata:
        name: ebs-sc
        annotations:
          storageclass.kubernetes.io/is-default-class: "true"
      provisioner: ebs.csi.aws.com
      volumeBindingMode: WaitForFirstConsumer
      parameters:
        type: gp3
        encrypted: "true"
      EOF
    EOT
  }
}

# Update PostgreSQL PVC to use the storage class
resource "null_resource" "update_postgresql_pvc" {
  depends_on = [null_resource.create_ebs_sc]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl delete pvc --all -n monitoring
      kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    EOT
  }
}