provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

terraform {
  backend "gcs" {}
}

resource "google_storage_bucket" "kops-cluster-store" {
  name = "kops-cluster-store"
  location = "${var.region}"
}

data "google_service_account" "service-account" {
  account_id = "${var.service-account}"
}

resource "google_storage_bucket_iam_binding" "kops-cluster-store-iams" {
  bucket = "${google_storage_bucket.kops-cluster-store.name}"
  role = "roles/storage.legacyBucketOwner"

  members = [
    "serviceAccount:${data.google_service_account.service-account.email}",
  ]
}
