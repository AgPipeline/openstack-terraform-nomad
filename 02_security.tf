resource "openstack_compute_secgroup_v2" "bastion" {
  name        = "${var.env_name}-bastion"
  description = "${var.env_name} - Bastion Server"

  rule {
    ip_protocol = "tcp"
    from_port   = "22"
    to_port     = "22"
    cidr        = "${var.bastion_allowed_cidr}"
  }
}

resource "openstack_compute_secgroup_v2" "consul_server" {
  name        = "${var.env_name}-consul_server"
  description = "${var.env_name} - Consul Server"

  rule {
    // Consul RPC
    ip_protocol = "tcp"
    from_port   = "8300"
    to_port     = "8300"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul LAN Gossip
    ip_protocol = "tcp"
    from_port   = "8301"
    to_port     = "8301"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul LAN Gossip
    ip_protocol = "udp"
    from_port   = "8301"
    to_port     = "8301"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul WAN Gossip
    ip_protocol = "tcp"
    from_port   = "8302"
    to_port     = "8302"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul WAN Gossip
    ip_protocol = "udp"
    from_port   = "8302"
    to_port     = "8302"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul (Something?) - See https://devopscube.com/setup-consul-cluster-guide/
    ip_protocol = "tcp"
    from_port   = "8400"
    to_port     = "8400"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul HTTP Server
    ip_protocol = "tcp"
    from_port   = "8500"
    to_port     = "8500"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul DNS Server
    ip_protocol = "tcp"
    from_port   = "8600"
    to_port     = "8600"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Consul DNS Server
    ip_protocol = "udp"
    from_port   = "8600"
    to_port     = "8600"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }
}
resource "openstack_compute_secgroup_v2" "nomad_server" {
  name        = "${var.env_name}-nomad_server"
  description = "${var.env_name} - Nomad Server"

  rule {
    // Nomad RPC
    ip_protocol = "tcp"
    from_port   = "4647"
    to_port     = "4647"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Nomad Gossip
    ip_protocol = "tcp"
    from_port   = "4648"
    to_port     = "4648"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

  rule {
    // Nomad Gossip
    ip_protocol = "udp"
    from_port   = "4648"
    to_port     = "4648"
    cidr        = "${openstack_networking_subnet_v2.subnet_1.cidr}"
  }

}
