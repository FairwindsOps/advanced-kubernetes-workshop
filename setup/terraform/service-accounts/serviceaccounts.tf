resource "null_resource" "auth" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.kubecontext} --zone ${var.zone} --project ${var.project}"
  }

  provisioner "local-exec" {
    command = "kubectx ${var.kubecontext}=\"gke_\"${var.project}\"_\"${var.zone}\"_\"${var.kubecontext}"
  }
}

resource "kubernetes_service_account" "tiller" {
  depends_on = ["null_resource.auth"]

  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "admins" {
  depends_on = ["kubernetes_service_account.tiller"]

  metadata {
    name = "cluster-admins"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = "${var.user}"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}

output "uid" {
  value       = "${kubernetes_cluster_role_binding.admins.metadata.0.uid}"
  description = "The UID of the clusterrolebinding indicates that this module is completed"
}
