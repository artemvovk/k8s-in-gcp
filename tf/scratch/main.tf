variable "list-of-ips" {
  default = ["127.0.0.1", "127.0.0.2", "127.0.0.3", "127.0.0.4"]
}

variable "list-of-names" {
  default = ["name1", "name2", "name3", "name4"]
}

output "zip_map" {
  value = "${zipmap(var.list-of-names, formatlist("%s:port1:port2", var.list-of-ips))}"
}
