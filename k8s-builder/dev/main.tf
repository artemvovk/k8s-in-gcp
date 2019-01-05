provider "google" {
  credentials = "${file("ACCOUNT.json")}"
  project     = "k8s-builder"
  region      = "us-west1-a"
}


terraform {
    backend "gcs" {}
}
