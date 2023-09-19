provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  gce_zone = "${var.region}-b"
}

resource "google_project_service" "enabled_services" {
  project            = var.project_id
  service            = each.key
  for_each           = toset(var.gcp_services_list)
  disable_on_destroy = false
}

resource "google_compute_network" "my_vpc" {
  project                 = var.project_id
  name                    = "my-vpc"
  auto_create_subnetworks = false
  depends_on = [ google_project_service.enabled_services ]
}

resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  project       = var.project_id
  ip_cidr_range = "192.168.0.0/24"
  region        = var.region
  network       = google_compute_network.my_vpc.id
}

resource "google_compute_instance" "my_www_vms" {
  for_each     = var.www_instances
  project      = var.project_id
  name         = "${var.vm_prefix}-${each.value.name_suffix}"
  machine_type = "${each.value.machine_type}"
  zone         =local.gce_zone

  tags = ["www"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.my_vpc.id
    subnetwork = google_compute_subnetwork.my_subnet.id
  }

  metadata_startup_script = "apt update && apt install -y nginx"
}

resource "google_compute_firewall" "allow_www" {
  name          = "allow-www"
  project       = var.project_id
  network       = google_compute_network.my_vpc.id
  source_ranges = ["192.168.0.0/24"]
  target_tags   = ["www"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_instance_group" "my_www_vms" {
  name        = "www-servers"
  description = "The instance group to the www servers"
  project     = var.project_id
  instances   = [for _,vm in google_compute_instance.my_www_vms : vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }

  zone = local.gce_zone
}