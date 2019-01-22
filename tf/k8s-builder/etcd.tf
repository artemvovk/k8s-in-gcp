# etcd Infra
data "template_file" "etcd-node-startup" {
  template = "${file("etcd_startup.sh.tpl")}"

  vars = {
    ETCD_DISCOVERY_TOKEN = "${var.etcd_discovery_token}"
  }
}

resource "google_compute_instance" "etcd-node" {
  count        = "3"
  name         = "etcd-node-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "${element(var.regions, count.index)}-b"

  tags = ["etcd", "node"]

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
    ETCD_VERSION            = "v2"
  }

  metadata_startup_script = "${data.template_file.etcd-node-startup.rendered}"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_firewall" "allow-etcd-egress-ports" {
  name      = "etcd-allow-egress-ports"
  project   = "${var.project}"
  network   = "${google_compute_network.k8s-network.name}"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["2379", "2380"]
  }

  target_tags = ["etcd", "k8s"]
}

resource "google_compute_firewall" "allow-etcd-ingress-ports" {
  name      = "etcd-allow-ingress-ports"
  project   = "${var.project}"
  network   = "${google_compute_network.k8s-network.name}"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["2379", "2380"]
  }

  source_tags = ["etcd", "k8s"]
}
