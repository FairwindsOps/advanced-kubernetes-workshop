// Configure the Google Cloud provider
provider "google" {
  version     = "~> 2.13.0"
  credentials = "${file("${var.credentials}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}
