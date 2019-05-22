# GCR

resource "google_pubsub_topic" "gcr" {
  name = "gcr"
}

resource "google_pubsub_subscription" "gcr" {
  name  = "my-gcr-sub"
  topic = "${google_pubsub_topic.gcr.name}"
}

# GCS
resource "google_pubsub_topic" "gcs" {
  name = "spin-gcs-topic"
}

resource "google_pubsub_subscription" "gcs" {
  name  = "my-gcs-sub"
  topic = "${google_pubsub_topic.gcs.name}"
}
