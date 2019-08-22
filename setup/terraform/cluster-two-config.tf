resource "null_resource" "gke-two-cluster" {
  depends_on = ["google_container_cluster.gke-two", "null_resource.gke-two-cluster"]

  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.gke-two.name} --zone ${google_container_cluster.gke-two.zone} --project ${google_container_cluster.gke-two.project}"
  }

  provisioner "local-exec" {
    command = "kubectx -d ${google_container_cluster.gke-two.name} || true; kubectx ${google_container_cluster.gke-two.name}=\"gke_\"${google_container_cluster.gke-two.project}\"_\"${google_container_cluster.gke-two.zone}\"_\"${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "kubectl get clusterrolebinding user-admin-binding --context ${google_container_cluster.gke-two.name} || kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account) --context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "kubectl get serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-two.name} || kubectl create serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "kubectl get clusterrolebinding tiller-admin-binding --context ${google_container_cluster.gke-two.name} || kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "helm init --service-account=tiller --kube-context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "until timeout 10 helm version; do sleep 10; done"
  }

  # install istio
  provisioner "local-exec" {
    command = "helm upgrade --install istio-init ~/istio-${var.istio-ver}/install/kubernetes/helm/istio-init --namespace istio-system --kube-context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "kubectl --context ${google_container_cluster.gke-two.name} -n istio-system wait --for condition=complete job/istio-init-crd-10 --timeout=300s"
  }

  provisioner "local-exec" {
    command = "kubectl --context ${google_container_cluster.gke-two.name} -n istio-system wait --for condition=complete job/istio-init-crd-11 --timeout=300s"
  }

  provisioner "local-exec" {
    command = "helm upgrade --install istio ~/istio-${var.istio-ver}/install/kubernetes/helm/istio --namespace istio-system --values ~/advanced-kubernetes-workshop/setup/istio-values.yaml --kube-context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "kubectl label namespace default istio-injection=enabled --context ${google_container_cluster.gke-two.name} --overwrite"
  }

  # /install istio

  provisioner "local-exec" {
    command = "kubectl apply -f ~/advanced-kubernetes-workshop/spinnaker/sa.yaml --context ${google_container_cluster.gke-two.name}"
  }
  provisioner "local-exec" {
    command = "kubectl config set-credentials ${google_container_cluster.gke-two.name}-token-user --token $(kubectl get secret --context ${google_container_cluster.gke-two.name} $(kubectl get serviceaccount spinnaker-service-account --context ${google_container_cluster.gke-two.name} -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)"
  }
  provisioner "local-exec" {
    command = "kubectl config set-context ${google_container_cluster.gke-two.name} --user ${google_container_cluster.gke-two.name}-token-user"
  }

  provisioner "local-exec" {
    command = "kubectl -n istio-system apply -f ~/advanced-kubernetes/setup/kiali-secret.yaml --kube-context ${google_container_cluster.gke-two.name}
  }

}
