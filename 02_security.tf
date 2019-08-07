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
