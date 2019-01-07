provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

module "backend-bucket" {
  source = "../modules/gcs-bucket"
  service_account = "${var.service_account}"
  project = "${var.project}"
  region = "${var.region}"
  key_link = "${var.key_link}"
  key_ring_link = "${var.key_ring_link}"
}
