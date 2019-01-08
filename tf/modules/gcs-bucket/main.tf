data "google_service_account" "service_account" {
  account_id = "${var.service_account}"
}

data "google_storage_project_service_account" "gcs_account" {}

resource "google_storage_bucket" "state_bucket" {
  name     = "tf-backend-state"
  location = "${var.region}"
  force_destroy = true
  encryption {
    default_kms_key_name = "${var.key_link}"
  }
}

resource "google_kms_key_ring_iam_binding" "key_ring_service_role_binding" {
  key_ring_id = "${var.key_ring_link}"
  role        = "roles/owner"

  members = [
    "serviceAccount:${data.google_service_account.service_account.email}",
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}


resource "google_kms_crypto_key_iam_binding" "encryption_key_service_role_binding" {
  crypto_key_id = "${var.key_link}"
  role          = "roles/owner"

  members = [
    "serviceAccount:${data.google_service_account.service_account.email}",
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}
