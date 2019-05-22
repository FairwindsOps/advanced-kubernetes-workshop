provider "helm" {
  install_tiller  = "true"
  service_account = "tiller"
  version         = "~> v0.9.0"
  namespace       = "kube-system"

  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "${var.kubecontext}"
  }
}
