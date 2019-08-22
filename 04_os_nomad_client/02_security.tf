resource "openstack_compute_secgroup_v2" "consul_client" {
  name        = "${var.env_name}-consul_client"
  description = "${var.env_name} - Consul Client"

  rule {
    // Consul RPC
    ip_protocol = "tcp"
    from_port   = "8300"
    to_port     = "8300"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul LAN Gossip
    ip_protocol = "tcp"
    from_port   = "8301"
    to_port     = "8301"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul LAN Gossip
    ip_protocol = "udp"
    from_port   = "8301"
    to_port     = "8301"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul WAN Gossip
    ip_protocol = "tcp"
    from_port   = "8302"
    to_port     = "8302"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul WAN Gossip
    ip_protocol = "udp"
    from_port   = "8302"
    to_port     = "8302"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul (Something?) - See https://devopscube.com/setup-consul-cluster-guide/
    ip_protocol = "tcp"
    from_port   = "8400"
    to_port     = "8400"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul HTTP Server
    ip_protocol = "tcp"
    from_port   = "8500"
    to_port     = "8500"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul DNS Server
    ip_protocol = "tcp"
    from_port   = "8600"
    to_port     = "8600"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul DNS Server
    ip_protocol = "udp"
    from_port   = "8600"
    to_port     = "8600"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }
}

resource "openstack_compute_secgroup_v2" "nomad_client" {
  name        = "${var.env_name}-nomad_client"
  description = "${var.env_name} - Nomad Client"

  rule {
    // Nomad RPC
    ip_protocol = "tcp"
    from_port   = "4647"
    to_port     = "4647"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Nomad Gossip
    ip_protocol = "tcp"
    from_port   = "4648"
    to_port     = "4648"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Nomad Gossip
    ip_protocol = "udp"
    from_port   = "4648"
    to_port     = "4648"
    cidr        = "${data.openstack_networking_subnet_v2.subnet_1.cidr}"
  }

}
