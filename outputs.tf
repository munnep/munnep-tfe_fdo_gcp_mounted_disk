output "tfe_instance" {
  value = "ssh ubuntu@${google_compute_address.tfe-public-ipc.address}"
}