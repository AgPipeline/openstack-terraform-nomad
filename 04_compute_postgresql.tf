resource "openstack_compute_instance_v2" "postgresql" {
  name              = "${var.env_name}-postgresql"
  flavor_name       = "${var.postgresql_flavor}"
  image_name        = "${var.postgresql_image}"
  key_pair          = "${openstack_compute_keypair_v2.terraform.name}"
  availability_zone = "${var.availability_zone}"

  network {
    name = "${var.env_name}-net"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.bastion.name}",
    "default",
  ]

  depends_on = [
    "openstack_networking_router_interface_v2.router_interface_1",
    "openstack_blockstorage_volume_v2.postgresql_data",
    "openstack_networking_subnet_v2.subnet_1"
  ]
}

resource "openstack_compute_floatingip_associate_v2" "postgresql_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.postgresql_ip.address}"
  instance_id = "${openstack_compute_instance_v2.postgresql.id}"
  fixed_ip    = "${openstack_compute_instance_v2.postgresql.network.0.fixed_ip_v4}"
}

resource "openstack_compute_volume_attach_v2" "postgresql_data" {
  volume_id   = "${openstack_blockstorage_volume_v2.postgresql_data.id}"
  instance_id = "${openstack_compute_instance_v2.postgresql.id}"
}

locals {
  postgresql_data_device = "${openstack_compute_volume_attach_v2.postgresql_data.device}"
}
