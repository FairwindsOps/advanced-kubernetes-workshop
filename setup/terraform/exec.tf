resource "null_resource" "local-exec-1" {
  depends_on = ["null_resource.gke-one-cluster", "null_resource.gke-two-cluster", "null_resource.gke-spinnaker-cluster", "google_pubsub_subscription.gcr", "google_pubsub_subscription.gcs", "google_storage_bucket_iam_member.allusersview"]

  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "sed -e s/REGION1/${var.grafana-region-1}/g -e s/REGION2/${var.grafana-region-2}/g ~/advanced-kubernetes-workshop/setup/grafana.sh | sh -"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/namespaces.yml --context ${google_container_cluster.gke-one.name}"
  }

  provisioner "local-exec" {
    command = "kubectl label namespace staging istio-injection=enabled --context ${google_container_cluster.gke-one.name} --overwrite"
  }

  provisioner "local-exec" {
    command = "kubectl label namespace production istio-injection=enabled --context ${google_container_cluster.gke-one.name} --overwrite"
  }

  provisioner "local-exec" {
    command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/seeding.yml | kubectl apply -f - --context ${google_container_cluster.gke-one.name}"
  }

  provisioner "local-exec" {
    command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/app-backend-dev.yml | kubectl apply -f -  --context ${google_container_cluster.gke-one.name}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/namespaces.yml --context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "kubectl label namespace staging istio-injection=enabled --context ${google_container_cluster.gke-two.name} --overwrite"
  }

  provisioner "local-exec" {
    command = "kubectl label namespace production istio-injection=enabled --context ${google_container_cluster.gke-two.name} --overwrite"
  }

  provisioner "local-exec" {
    command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/seeding.yml | kubectl apply -f - --context ${google_container_cluster.gke-two.name}"
  }

  provisioner "local-exec" {
    command = "sed -e s/PROJECT_ID/${google_container_cluster.gke-one.project}/g ~/advanced-kubernetes-workshop/services/manifests/app-backend-dev.yml | kubectl apply -f -  --context ${google_container_cluster.gke-two.name}"
  }
}
