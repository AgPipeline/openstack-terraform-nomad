resource "openstack_compute_instance_v2" "mongo_opsmanager" {
  name              = "${var.env_name}-mongo-opsmanager"
  flavor_name       = "${var.mongo_opsmanager_flavor}"
  image_name        = "${var.mongo_opsmanager_image}"
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
    "openstack_blockstorage_volume_v2.mongo_opsmanager_data",
    "openstack_networking_subnet_v2.subnet_1"
  ]
}

resource "openstack_compute_volume_attach_v2" "mongo_opsmanager_data" {
  volume_id   = "${openstack_blockstorage_volume_v2.mongo_opsmanager_data.id}"
  instance_id = "${openstack_compute_instance_v2.mongo_opsmanager.id}"
}

locals {
  mongo_opsmanager_data_device = "${openstack_compute_volume_attach_v2.mongo_opsmanager_data.device}"
}

output mongo-opsmanager-instance-fixed-ip {
  value = "${openstack_compute_instance_v2.mongo_opsmanager.network.0.fixed_ip_v4}"
}
