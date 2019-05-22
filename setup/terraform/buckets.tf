resource "google_storage_bucket" "spinnaker" {
  name     = "${var.project}-spinnaker"
  location = "US"
}

resource "google_storage_bucket" "spinnaker-config" {
  name     = "${var.project}-spinnaker-config"
  location = "US"
}

resource "google_storage_bucket_object" "frontend-manifest" {
  name   = "manifests/frontend.yml"
  source = "${var.homedir}/advanced-kubernetes-workshop/services/manifests/frontend.yml"
  bucket = "${google_storage_bucket.spinnaker.name}"
}

resource "google_storage_bucket_object" "backend-manifest" {
  name   = "manifests/backend.yml"
  source = "${var.homedir}/advanced-kubernetes-workshop/services/manifests/backend.yml"
  bucket = "${google_storage_bucket.spinnaker.name}"
}

# Make the root GCR repo public
# gsutil iam ch allUsers:objectViewer gs://artifacts.$PROJECT.appspot.com
resource "google_storage_bucket_iam_member" "allusersview" {
  bucket = "artifacts.${var.project}.appspot.com"
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
