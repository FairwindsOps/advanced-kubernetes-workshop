resource "null_resource" "gke-spinnaker-cluster" {
  depends_on = ["google_container_cluster.gke-spinnaker", "null_resource.gke-two-cluster"]

  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.gke-spinnaker.name} --zone ${google_container_cluster.gke-spinnaker.zone} --project ${google_container_cluster.gke-spinnaker.project}"
  }

  provisioner "local-exec" {
    command = "kubectx -d ${google_container_cluster.gke-spinnaker.name} || true; kubectx ${google_container_cluster.gke-spinnaker.name}=\"gke_\"${google_container_cluster.gke-spinnaker.project}\"_\"${google_container_cluster.gke-spinnaker.zone}\"_\"${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "kubectl get clusterrolebinding user-admin-binding --context ${google_container_cluster.gke-spinnaker.name} || kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account) --context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "kubectl get serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-spinnaker.name} || kubectl create serviceaccount tiller --namespace kube-system --context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "kubectl get clusterrolebinding tiller-admin-binding --context ${google_container_cluster.gke-spinnaker.name} || kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "helm init --service-account=tiller --kube-context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "until timeout 10 helm version; do sleep 10; done"
  }

  provisioner "local-exec" {
    command = "helm upgrade --install spin stable/spinnaker -f ~/advanced-kubernetes-workshop/setup/spinconfig.yaml --timeout=600 --version 1.6.1 --kube-context ${google_container_cluster.gke-spinnaker.name}"
  }

  # install istio
  provisioner "local-exec" {
    command = "helm upgrade --install istio-init ~/istio-${var.istio-ver}/install/kubernetes/helm/istio-init --namespace istio-system --kube-context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "kubectl --context ${google_container_cluster.gke-spinnaker.name} -n istio-system wait --for condition=complete job/istio-init-crd-10 --timeout=30s"
  }

  provisioner "local-exec" {
    command = "kubectl --context ${google_container_cluster.gke-spinnaker.name} -n istio-system wait --for condition=complete job/istio-init-crd-11 --timeout=30s"
  }

  provisioner "local-exec" {
    command = "helm upgrade --install istio ~/istio-${var.istio-ver}/install/kubernetes/helm/istio --namespace istio-system --values ~/advanced-kubernetes-workshop/setup/istio-values.yaml --kube-context ${google_container_cluster.gke-spinnaker.name}"
  }

  # /install istio
  provisioner "local-exec" {
    command = "kubectl apply -f ~/istio-${var.istio-ver}/samples/httpbin/sample-client/fortio-deploy.yaml --context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ~/advanced-kubernetes-workshop/spinnaker/sa.yaml --context ${google_container_cluster.gke-spinnaker.name}"
  }

  provisioner "local-exec" {
    command = "kubectl config set-credentials gke-spinnaker-token-user --token $(kubectl get secret --context gke-spinnaker $(kubectl get serviceaccount spinnaker-service-account --context gke-spinnaker -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)"
  }

  provisioner "local-exec" {
    command = "kubectl config set-context gke-spinnaker --user gke-spinnaker-token-user"
  }
}
