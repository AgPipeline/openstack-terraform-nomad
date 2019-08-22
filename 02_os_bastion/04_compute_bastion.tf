resource "openstack_compute_instance_v2" "bastion" {
  name              = "${var.env_name}-bastion"
  flavor_name       = "${var.flavor}"
  image_name        = "${var.image}"
  key_pair          = "${openstack_compute_keypair_v2.terraform.name}"

  network {
    name = "${var.env_name}-net"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.bastion.name}",
    "default",
  ]

  depends_on = [
    data.openstack_networking_subnet_v2.subnet_1
  ]
}

resource "openstack_compute_floatingip_associate_v2" "bastion_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.bastion_ip.address}"
  instance_id = "${openstack_compute_instance_v2.bastion.id}"
  fixed_ip    = "${openstack_compute_instance_v2.bastion.network.0.fixed_ip_v4}"
}


output bastion-instance-floating-ip {
  value = "${openstack_networking_floatingip_v2.bastion_ip.address}"
}
