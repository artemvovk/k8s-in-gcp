provider "google" {
  project = "k8s-builder"
  region  = "us-central1"
}

data "google_kms_key_ring" "my-ring" {
  name     = "tf-state-key-ring"
  location = "us-central1"
}

data "google_kms_crypto_key" "my-key" {
  name     = "tf-state-key"
  key_ring = "${data.google_kms_key_ring.my-ring.self_link}"
}

variable "list-of-ips" {
  default = ["127.0.0.1", "127.0.0.2", "127.0.0.3", "127.0.0.4"]
}

variable "list-of-names" {
  default = ["name1", "name2", "name3", "name4"]
}

output "ring" {
  value = "${data.google_kms_key_ring.my-ring.self_link}"
}

output "key" {
  value = "${data.google_kms_crypto_key.my-key.name}"
}

output "zip_map" {
  value = "${zipmap(var.list-of-names, formatlist("%s:port1:port2", var.list-of-ips))}"
}
