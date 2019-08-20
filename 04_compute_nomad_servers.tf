resource "openstack_compute_instance_v2" "nomad_server" {
  count             = "${var.nomad_server_count}"
  name              = "${var.env_name}-nomad_server${count.index}"
  flavor_name       = "${var.nomad_server_flavor}"
  image_name        = "${var.nomad_server_image}"
  key_pair          = "${openstack_compute_keypair_v2.terraform.name}"
  availability_zone = "${var.availability_zone}"

  network {
    name = "${var.env_name}-net"
  }

  security_groups = [
    "default",
  ]

  depends_on = [
    "openstack_networking_router_interface_v2.router_interface_1",
    "openstack_networking_subnet_v2.subnet_1"
  ]

}

output nomad-servers-fixed-ips {
  value = "${openstack_compute_instance_v2.nomad_server.*.network.0.fixed_ip_v4}"
}
