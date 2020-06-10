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
  name    = "${var.name}-allow-es-rule"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["9200", "9300"]
  }

  source_tags = var.network_tags

}

//Creating Instance-1

resource "google_compute_address" "internal_with_subnet_and_address1" {
  name         = "${var.name}-internal-address1"
  subnetwork   = google_compute_subnetwork.subnet1.id
  address_type = "INTERNAL"
  address      = "10.0.0.3"
  region       = var.region
}

resource "google_compute_instance" "vm_instance_public1" {
  name = "${var.name}-vm-1"
  machine_type = "n1-standard-2"
  zone = "us-west1-a"
  tags = ["allow-es"]

 boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet1.id
    network_ip = google_compute_address.internal_with_subnet_and_address1.address
    access_config {
    }
  }
  depends_on = ["google_compute_subnetwork.subnet1"]
}

resource "google_compute_disk" "disk1" {
  name  = "${var.name}-disk1"
  type  = "pd-ssd"
  size  = "30"
  zone  = "us-west1-a"
  physical_block_size_bytes = 4096
}
resource "google_compute_attached_disk" "disk1" {
  disk     = google_compute_disk.disk1.id
  instance = google_compute_instance.vm_instance_public1.id
}


// Creating Instance-2

resource "google_compute_address" "internal_with_subnet_and_address2" {
  name         = "${var.name}-internal-address2"
  subnetwork   = google_compute_subnetwork.subnet2.id
  address_type = "INTERNAL"
  address      = "10.1.0.3"
  region       = var.region
}

resource "google_compute_instance" "vm_instance_public2" {
  name = "${var.name}-vm-2"
  machine_type = "n1-standard-2"
  zone = "us-west1-a"
  tags = ["allow-es"]

 boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet2.id
    network_ip = google_compute_address.internal_with_subnet_and_address2.address

     access_config {
    }
  }
  depends_on = ["google_compute_subnetwork.subnet2"]
}

resource "google_compute_disk" "disk2" {
  name  = "${var.name}-disk-2"
  type  = "pd-ssd"
  size  = "30"
  zone  = "us-west1-a"
  physical_block_size_bytes = 4096
}
resource "google_compute_attached_disk" "disk2" {
  disk     = google_compute_disk.disk2.id
  instance = google_compute_instance.vm_instance_public2.id
}


