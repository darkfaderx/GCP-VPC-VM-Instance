// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.credentials}")}"
 project     = "${var.gcp_project}" 
 region      = "${var.region}"
}

// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet-1
resource "google_compute_subnetwork" "subnet1" {
 name          = "${var.name}-subnet1"
 ip_cidr_range = "${var.subnet1_cidr}"
 network       = "${var.name}-vpc"
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.region}"
}


// Create Subnet-2
resource "google_compute_subnetwork" "subnet2" {
 name          = "${var.name}-subnet2"
 ip_cidr_range = "${var.subnet2_cidr}"
 network       = "${var.name}-vpc"
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.region}"
}


// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["9200", "9300"]
  }

  source_tags = ["allow-es"]

}
