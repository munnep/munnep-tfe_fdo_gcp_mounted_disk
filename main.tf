resource "google_compute_network" "tfe_vpc" {
  name                    = "${var.tag_prefix}-vpc"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "tfe_subnet" {
  name          = "${var.tag_prefix}-public1"
  ip_cidr_range = cidrsubnet(var.vnet_cidr, 8, 1)
  network       = google_compute_network.tfe_vpc.self_link
}

resource "google_compute_router" "tfe_router" {
  name    = "${var.tag_prefix}-router"
  network = google_compute_network.tfe_vpc.self_link
}


resource "google_compute_instance" "tfe" {
  name         = var.tag_prefix
  machine_type = "n2-standard-8"
  zone         = "europe-west4-a"



  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20240207"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network    = "tfe23-vpc"
    subnetwork = "tfe23-public1"

    access_config {
      // Ephemeral public IP
      nat_ip = google_compute_address.tfe-public-ipc.address
    }
  }

  metadata = {
    "ssh-keys" = "ubuntu:${var.public_key}"
    "user-data" = templatefile("${path.module}/scripts/cloudinit_tfe_server.yaml", {
      tag_prefix        = var.tag_prefix
      dns_hostname      = var.dns_hostname
      tfe_password      = var.tfe_password
      dns_zonename      = var.dns_zonename
      tfe_release       = var.tfe_release
      tfe_license       = var.tfe_license
      certificate_email = var.certificate_email
      full_chain        = base64encode("${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}")
      private_key_pem   = base64encode(lookup(acme_certificate.certificate, "private_key_pem"))
    })
  }


  depends_on = [google_compute_subnetwork.tfe_subnet]
}

resource "google_compute_address" "tfe-public-ipc" {
  name         = "tfe-public-ip"
  address_type = "EXTERNAL"
}


resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.tfe_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
