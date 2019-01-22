provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}

provider "template" {}

terraform {
  backend "gcs" {}
}

data "google_service_account" "service-account" {
  account_id = "${var.service_account}"
}

resource "google_storage_bucket" "kops-cluster-store" {
  name     = "${var.kops_store}"
  location = "${var.region}"
}

resource "google_dns_managed_zone" "dns-zone" {
  name        = "k8s-zone"
  dns_name    = "k8s.artemavovk.com."
  description = "Simple K8s domain zone"
}

# Cluster Infra
data "template_file" "k8s-master-startup" {
  template = "${file("master_startup.sh.tpl")}"
}

data "template_file" "k8s-node-startup" {
  template = "${file("node_startup.sh.tpl")}"
}

resource "google_compute_instance" "k8s-master" {
  name         = "k8s-master"
  machine_type = "n1-standard-2"
  zone         = "${var.regions[3]}-b"

  tags = ["k8s", "master"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.k8s-subnet.*.name[3]}"
  }

  metadata = {
    ssh-keys                = "artem:${file("~/.ssh/id_rsa.pub")}"
    KUBERNETES_SKIP_CONFIRM = "true"
    KUBERNETES_RELEASE      = "v1.13.2"
  }

  metadata_startup_script = "${data.template_file.k8s-master-startup.rendered}"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_instance" "k8s-node" {
  count        = "2"
  name         = "k8s-node-${count.index}"
  machine_type = "n1-standard-2"
  zone         = "${element(var.regions, count.index)}-a"

  tags = ["k8s", "worker"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.k8s-subnet.*.name, count.index)}"
  }

  metadata = {
    ssh-keys                = "artem:${file("~/.ssh/id_rsa.pub")}"
    KUBERNETES_SKIP_CONFIRM = "true"
    KUBERNETES_RELEASE      = "v1.13.2"
  }

  metadata_startup_script = "${data.template_file.k8s-node-startup.rendered}"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
