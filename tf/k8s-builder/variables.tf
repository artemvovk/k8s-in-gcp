variable "region" {}
variable "project" {}
variable "service_account" {}
variable "kops_store" {}
variable "etcd_discovery_token" {}

variable "regions" {
  default = ["us-central1", "us-west1", "us-west2", "us-east1"]
}
