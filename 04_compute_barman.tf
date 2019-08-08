resource "openstack_compute_instance_v2" "barman" {
  name              = "${var.env_name}-barman"
  flavor_name       = "${var.barman_flavor}"
  image_name        = "${var.barman_image}"
  key_pair          = "${openstack_compute_keypair_v2.terraform.name}"
  availability_zone = "${var.availability_zone}"

  network {
    name = "${var.env_name}-net"
  }

  security_groups = [
    "default"
  ]

  depends_on = [
    "openstack_networking_router_interface_v2.router_interface_1",
    "openstack_networking_subnet_v2.subnet_1"
  ]
}

output barman-instance-fixed-ip {
  value = "${openstack_compute_instance_v2.barman.network.0.fixed_ip_v4}"
}
