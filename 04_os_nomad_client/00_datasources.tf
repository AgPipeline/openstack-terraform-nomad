data "openstack_images_image_v2" "nomad_client_image" {
  name        = var.nomad_client_image
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


// See: https://github.com/terraform-providers/terraform-provider-openstack/issues/512
data "openstack_networking_secgroup_v2" "consul_server" {
  name = "${var.env_name}-consul_server"
}

data "openstack_networking_port_ids_v2" "consul_server_port_ids" {
  security_group_ids = [data.openstack_networking_secgroup_v2.consul_server.id]
}

data "openstack_networking_port_v2" "consul_server_port" {
  count = "${length(data.openstack_networking_port_ids_v2.consul_server_port_ids.ids)}"
  port_id = "${element(data.openstack_networking_port_ids_v2.consul_server_port_ids.ids, count.index)}"
}
