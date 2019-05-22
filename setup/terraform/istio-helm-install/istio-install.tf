resource "helm_release" "istio-init" {
  name      = "istio-init"
  namespace = "istio-system"
  chart     = "./istio-${var.istio-version}/install/kubernetes/helm/istio-init"
  timeout   = 1200
}

resource "helm_release" "istio" {
  depends_on = ["null_resource.istio-init-wait"]
  name       = "istio"
  namespace  = "istio-system"
  chart      = "./istio-${var.istio-version}/install/kubernetes/helm/istio"
  timeout    = 1200

  values = [
    "${file("./istio-${var.istio-version}/install/kubernetes/helm/istio/values-istio-demo-auth.yaml")}",
  ]
}

resource "null_resource" "istio-init-wait" {
  provisioner "local-exec" {
    command = "kubectl --context ${var.kubecontext} -n istio-system wait --for condition=complete job/istio-init-crd-10 --timeout=30s"
  }

  provisioner "local-exec" {
    command = "kubectl --context ${var.kubecontext} -n istio-system wait --for condition=complete job/istio-init-crd-11 --timeout=30s"
  }
}
