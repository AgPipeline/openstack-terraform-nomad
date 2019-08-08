resource "openstack_compute_instance_v2" "mongo" {
  count             = "${var.mongo_count}"
  name              = "${var.env_name}-mongo${count.index}"
  flavor_name       = "${var.mongo_flavor}"
  image_name        = "${var.mongo_image}"
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
    "openstack_blockstorage_volume_v2.mongo_data",
    "openstack_networking_subnet_v2.subnet_1"
  ]

}

resource "openstack_compute_volume_attach_v2" "mongo_data" {
  count       = "${var.mongo_count}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.mongo_data.*.id, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.mongo.*.id, count.index)}"
}

output mongo-instances-fixed-ips {
  value = "${openstack_compute_instance_v2.mongo.*.network.0.fixed_ip_v4}"
}
