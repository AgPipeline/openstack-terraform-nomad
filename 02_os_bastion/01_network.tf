resource "openstack_networking_floatingip_v2" "bastion_ip" {
  pool = "${var.pool_name}"
}