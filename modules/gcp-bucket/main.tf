provider "google" {
  credentials = "${file("ACCOUNT.json")}"
  project     = "k8s-builder"
  region      = "us-west1"
}

data "google_service_account" "service-account" {
  account_id = "tf-cli"
}

data "google_storage_project_service_account" "gcs-account" {}

resource "google_kms_key_ring" "encryption-key-ring" {
  name     = "tf-state-key-ring"
  project  = "k8s-builder"
  location = "us-west1"
}

resource "google_kms_crypto_key" "encryption-key" {
  name            = "tf-state-key"
  key_ring        = "${google_kms_key_ring.encryption-key-ring.self_link}"
  rotation_period = "604800s"
}

resource "google_storage_bucket" "state-bucket" {
  name     = "tf-backend-state"
  location = "us-west1"
  force_destroy = true
  encryption {
    default_kms_key_name = "${google_kms_crypto_key.encryption-key.self_link}"
  }
}

resource "google_kms_key_ring_iam_binding" "encryption-key-ring-service-role-binding" {
  key_ring_id = "${google_kms_key_ring.encryption-key-ring.self_link}"
  role        = "roles/owner"

  members = [
    "serviceAccount:${data.google_service_account.service-account.email}",
    "serviceAccount:${data.google_storage_project_service_account.gcs-account.email_address}",
  ]
}


resource "google_kms_crypto_key_iam_binding" "encryption-key-service-role-binding" {
  crypto_key_id = "${google_kms_crypto_key.encryption-key.self_link}"
  role          = "roles/owner"

  members = [
    "serviceAccount:${data.google_service_account.service-account.email}",
    "serviceAccount:${data.google_storage_project_service_account.gcs-account.email_address}",
  ]
}

resource "google_storage_bucket_object" "state-lock" {
  name   = "/k8s-builder/default.tflock"
  content = " "
  bucket = "${google_storage_bucket.state-bucket.name}"
}

