# Subnets One
variable "one_node_ip_cidr" {
  default = "10.0.0.0/16"
}

variable "one_pod_ip_cidr" {
  default = "10.1.0.0/16"
}

variable "one_svc1_ip_cidr" {
  default = "10.2.0.0/16"
}

variable "one_subnet_count" {
  default = 2
}

# Subnets Two
variable "region-two" {
  default = "us-west1"
}

variable "two_node_ip_cidr" {
  default = "10.10.0.0/16"
}

variable "two_pod_ip_cidr" {
  default = "10.11.0.0/16"
}

variable "two_svc1_ip_cidr" {
  default = "10.12.0.0/16"
}

variable "two_subnet_count" {
  default = 2
}
