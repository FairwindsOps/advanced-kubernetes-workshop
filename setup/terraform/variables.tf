# Main variables
variable "region" {
  default = "us-central1"
}

variable "project" {
  # Set by the setup script in a flag
}

variable "credentials" {
  default = "./credentials.json"
}

variable "vpc" {
  default = "k8s"
}

# gke-one
variable "gke-one-name" {
  default = "gke-central"
}

variable "gke-one-zone" {
  default = "us-central1-f"
}

variable "network" {
  default = "default"
}

variable "min_master_version" {
  default = "1.11"
}

variable "machine_type" {
  default = "n1-standard-4"
}

variable "image_type" {
  default = "cos"
}

# gke-two
variable "gke-two-name" {
  default = "gke-west"
}

variable "gke-two-zone" {
  default = "us-west1-b"
}

# gke-spinnaker
variable "gke-spinnaker-name" {
  default = "gke-spinnaker"
}

variable "gke-spinnaker-zone" {
  default = "us-central1-f"
}

# Istio version
variable "istio-ver" {
  # Set by the setup script in a flag
}

variable "homedir" {
  # Set by the setup script in a flag
}

variable "user" {}
