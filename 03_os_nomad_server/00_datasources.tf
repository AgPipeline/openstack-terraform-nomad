data "openstack_images_image_v2" "nomad_server_image" {
  name        = var.nomad_server_image
  most_recent = true

  properties = {
    key = "value"
  }
}

data "openstack_networking_network_v2" "network_1" {
  name           = "${var.env_name}-net"
}

data "openstack_networking_subnet_v2" "subnet_1" {
  name            = "${var.env_name}-subnet"
  network_id      = "${data.openstack_networking_network_v2.network_1.id}"
}

data "openstack_compute_keypair_v2" "terraform" {
  name       = "${var.env_name}-tf-key_pair"
}

data "openstack_networking_floatingip_v2" "bastion_ip" {
  tags = ["${var.pool_name}-${var.env_name}-bastion"]
}
