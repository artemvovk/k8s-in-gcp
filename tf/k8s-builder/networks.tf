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
