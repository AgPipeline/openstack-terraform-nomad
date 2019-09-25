resource "openstack_networking_floatingip_v2" "bastion_ip" {
  pool = "${var.pool_name}"
  description = "Bastion floating ip"
  tags = ["${var.pool_name}-${var.env_name}-bastion"]
}