data "template_file" "k8s-bastion-startup" {
  template = "${file("bastion_startup.sh.tpl")}"
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

  metadata_startup_script = "${data.template_file.k8s-bastion-startup.rendered}"

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

  target_tags = ["ssh", "k8s", "etcd"]
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
