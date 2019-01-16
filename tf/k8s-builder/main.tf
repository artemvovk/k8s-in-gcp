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

# resource "google_storage_bucket_iam_binding" "kops-cluster-store-iams" {
#   bucket = "${google_storage_bucket.kops-cluster-store.name}"
#   role   = "roles/storage.legacyBucketOwner"
#
#   members = [
#     "projectOwner:${var.project}",
#     "serviceAccount:${data.google_service_account.service-account.email}",
#     "projectEditor:${var.project}",
#   ]
# }

resource "google_dns_managed_zone" "dns-zone" {
  name        = "k8s-zone"
  dns_name    = "k8s.artemavovk.com."
  description = "Simple K8s domain zone"
}

# Cluster Infra
variable "regions" {
  default = ["us-central1", "us-west1", "us-west2", "us-east1"]
}

resource "google_compute_network" "k8s-network" {
  name                    = "k8s-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s-subnet" {
  count         = "4"
  name          = "k8s-node-network-${count.index}"
  ip_cidr_range = "10.10.${count.index}.0/24"
  region        = "${element(var.regions, count.index)}"
  network       = "${google_compute_network.k8s-network.self_link}"
}

resource "google_compute_instance" "bastion" {
  name         = "k8s-bastion"
  machine_type = "n1-standard-1"
  zone         = "${var.regions[3]}-b"

  tags = ["k8s", "bastion"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.k8s-subnet.*.name[3]}"
    access_config = {}
  }

  metadata {
    ssh-keys = "artem:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

resource "google_compute_firewall" "allow-ssh-from-everywhere-to-bastion" {
  name    = "k8s-allow-ssh-from-everywhere-to-bastion"
  project = "${var.project}"
  network = "${google_compute_network.k8s-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["bastion"]
}

resource "google_compute_firewall" "allow-ssh-from-bastion-to-webservers" {
  name      = "k8s-allow-ssh-from-bastion-to-webservers"
  project   = "${var.project}"
  network   = "${google_compute_network.k8s-network.name}"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}

resource "google_compute_firewall" "allow-ssh-to-webservers-from-bastion" {
  name      = "k8s-allow-ssh-to-private-network-from-bastion"
  project   = "${var.project}"
  network   = "${google_compute_network.k8s-network.name}"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["bastion"]
}

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
  count        = "3"
  name         = "k8s-node-${count.index}"
  machine_type = "n1-standard-2"
  zone         = "${element(var.regions, count.index)}-a"

  tags = ["k8s", "node"]

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

resource "google_compute_router" "k8s-router" {
  count   = "4"
  name    = "k8s-router-${count.index}"
  region  = "${element(var.regions, count.index)}"
  network = "${google_compute_network.k8s-network.name}"
}

resource "google_compute_router_nat" "k8s-nat" {
  count                              = "4"
  name                               = "k8s-subnet-nat-${count.index}"
  router                             = "${element(google_compute_router.k8s-router.*.name, count.index)}"
  region                             = "${element(var.regions, count.index)}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork = {
    name = "${element(google_compute_subnetwork.k8s-subnet.*.self_link, count.index)}"
  }
}
