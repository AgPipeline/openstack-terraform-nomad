data "openstack_networking_network_v2" "external" {
  name = "${var.external_network_name}"
}

data "openstack_networking_network_v2" "network_1" {
  name           = "${var.env_name}-net"
}

data "openstack_networking_subnet_v2" "subnet_1" {
  name            = "${var.env_name}-subnet"
  network_id      = "${data.openstack_networking_network_v2.network_1.id}"
}

data "openstack_networking_router_v2" "router_1" {
  name                = "${var.env_name}-router"
}
