# Configure VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.vpc}"
  project                 = "${var.project}"
  auto_create_subnetworks = "false"
}

# Create firewall rule to allow all for k8s internally
resource "google_compute_firewall" "allow-all-k8s" {
  name    = "allow-all-k8s"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/12"]
}

resource "google_compute_subnetwork" "subnet-one" {
  count         = "${var.one_subnet_count}"
  name          = "subnet-${count.index}"
  project       = "${var.project}"
  ip_cidr_range = "${cidrsubnet(var.one_node_ip_cidr, 4, count.index)}"
  network       = "${var.vpc}"
  region        = "${var.region}"

  secondary_ip_range = {
    range_name    = "one-pod-${replace(replace(cidrsubnet(var.one_pod_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
    ip_cidr_range = "${cidrsubnet(var.one_pod_ip_cidr, 4, count.index)}"
  }

  secondary_ip_range = {
    range_name    = "one-svc1-${replace(replace(cidrsubnet(var.one_svc1_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
    ip_cidr_range = "${cidrsubnet(var.one_svc1_ip_cidr, 4, count.index)}"
  }

  depends_on = ["google_compute_network.vpc"]
}

resource "google_compute_subnetwork" "subnet-two" {
  count         = "${var.two_subnet_count}"
  name          = "subnet-${count.index}"
  project       = "${var.project}"
  ip_cidr_range = "${cidrsubnet(var.two_node_ip_cidr, 4, count.index)}"
  network       = "${var.vpc}"
  region        = "${var.region-two}"

  secondary_ip_range = {
    range_name    = "two-pod-${replace(replace(cidrsubnet(var.two_pod_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
    ip_cidr_range = "${cidrsubnet(var.two_pod_ip_cidr, 4, count.index)}"
  }

  secondary_ip_range = {
    range_name    = "two-svc1-${replace(replace(cidrsubnet(var.two_svc1_ip_cidr, 4, count.index), ".", "-"), "/", "-")}"
    ip_cidr_range = "${cidrsubnet(var.two_svc1_ip_cidr, 4, count.index)}"
  }

  depends_on = ["google_compute_network.vpc"]
}
