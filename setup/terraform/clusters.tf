resource "google_container_cluster" "gke-one" {
  name               = "${var.gke-one-name}"
  location           = "${var.gke-one-zone}"
  network            = "${var.vpc}"
  min_master_version = "${var.min_master_version}"
  initial_node_count = 4
  subnetwork         = "${element(google_compute_subnetwork.subnet-one.*.self_link, 0)}"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_allocation_policy {
    cluster_secondary_range_name  = "one-pod-${replace(replace(cidrsubnet(var.one_pod_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
    services_secondary_range_name = "one-svc1-${replace(replace(cidrsubnet(var.one_svc1_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    image_type   = "${var.image_type}"
  }

  depends_on = ["google_compute_subnetwork.subnet-one"]
}

resource "google_container_cluster" "gke-two" {
  name               = "${var.gke-two-name}"
  location           = "${var.gke-two-zone}"
  network            = "${var.vpc}"
  min_master_version = "${var.min_master_version}"
  initial_node_count = 4
  subnetwork         = "${element(google_compute_subnetwork.subnet-two.*.self_link, 0)}"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_allocation_policy {
    cluster_secondary_range_name  = "two-pod-${replace(replace(cidrsubnet(var.two_pod_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
    services_secondary_range_name = "two-svc1-${replace(replace(cidrsubnet(var.two_svc1_ip_cidr, 4, 0), ".", "-"), "/", "-")}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    image_type   = "${var.image_type}"
  }

  depends_on = ["google_compute_subnetwork.subnet-two"]
}

resource "google_container_cluster" "gke-spinnaker" {
  name               = "${var.gke-spinnaker-name}"
  location           = "${var.gke-spinnaker-zone}"
  min_master_version = "${var.min_master_version}"
  network            = "${var.vpc}"
  initial_node_count = 4
  subnetwork         = "${element(google_compute_subnetwork.subnet-one.*.self_link, 1)}"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_allocation_policy {
    cluster_secondary_range_name  = "one-pod-${replace(replace(cidrsubnet(var.one_pod_ip_cidr, 4, 1), ".", "-"), "/", "-")}"
    services_secondary_range_name = "one-svc1-${replace(replace(cidrsubnet(var.one_svc1_ip_cidr, 4, 1), ".", "-"), "/", "-")}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    image_type   = "${var.image_type}"
  }

  depends_on = ["google_compute_subnetwork.subnet-one"]
}
