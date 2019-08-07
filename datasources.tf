data "openstack_networking_network_v2" "external" {
  name = "${var.external_network_name}"
}
