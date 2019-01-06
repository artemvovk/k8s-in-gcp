provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

module "backend-bucket" {
  source = "../modules/gcs-bucket"
  service-account = "${var.service-account}"
  project = "${var.project}"
  region = "${var.region}"
  key-ring-name = "${var.key-ring-name}"
}
