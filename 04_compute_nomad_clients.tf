resource "openstack_compute_instance_v2" "nomad_client" {
  count             = "${var.nomad_client_count}"
  name              = "${var.env_name}-nomad_client${count.index}"
  flavor_name       = "${var.nomad_client_flavor}"
  image_name        = "${var.nomad_client_image}"
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

output nomad-clients-fixed-ips {
  value = "${openstack_compute_instance_v2.nomad_client.*.network.0.fixed_ip_v4}"
}
