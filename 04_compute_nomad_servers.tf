//resource "null_resource" "discovery_url_template" {
//  provisioner "local-exec" {
//    command = "curl -s 'https://discovery.etcd.io/new?size=${var.nomad_server_count}' > ${var.discovery_url_file}"
//  }
//}
//
//resource "template_file" "discovery_url" {
//  template = "${var.discovery_url_file}"
//  depends_on = [
//    "null_resource.discovery_url_template"
//  ]
//}

resource "openstack_compute_instance_v2" "nomad_server" {
  count             = var.nomad_server_count
  name              = "${var.env_name}-nomad_server${count.index}"
  flavor_name       = var.nomad_server_flavor
//  image_name        = var.nomad_server_image
  key_pair          = openstack_compute_keypair_v2.terraform.name
  availability_zone = var.availability_zone
  user_data         = templatefile("templates/install_consul_nomad.sh",
    {
      RETRY_JOIN = openstack_networking_floatingip_v2.consul_discovery_node_ip.address,
//      RETRY_JOIN = "192.168.0.8",
      CONSUL_VERSION="1.5.2",
      NOMAD_VERSION="0.9.4"
    }
  )

  block_device {
    uuid                  = data.openstack_images_image_v2.nomad_server_image.id
    source_type           = "image"
    volume_size           = var.nomad_server_vol_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "${var.env_name}-net"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.consul_server.name}",
    "${openstack_compute_secgroup_v2.nomad_server.name}",
    "default",
  ]

  depends_on = [
//    "local_file.discovery_url",
    "openstack_networking_router_interface_v2.router_interface_1",
    "openstack_networking_subnet_v2.subnet_1",
    "openstack_compute_instance_v2.bastion"
  ]

  //  connection {
  //    agent = "true"
  //    type = "ssh"
  //    host = openstack_compute_instance_v2.nomad_server.*.network.0.fixed_ip_v4[count.index]
  ////    user = "core"
  //    user = "ubuntu"
  //    private_key = file(var.privkey)
  //    bastion_host = openstack_networking_floatingip_v2.bastion_ip.address
  //    bastion_private_key = file(var.privkey)
  //  }

  //  provisioner "remote-exec" {
  //    inline = [
  //      "git clone --branch v0.5.0 --depth 1 https://github.com/hashicorp/terraform-aws-nomad.git",
  //      "terraform-aws-nomad/modules/install-nomad/install-nomad --version 0.9.4",
  ////      "/opt/nomad/bin/run-nomad --server --num-servers ${var.nomad_server_count}}"
  //    ]
  //  }

}

resource "openstack_compute_floatingip_associate_v2" "consul_discovery_node_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.consul_discovery_node_ip.address}"
  instance_id = "${openstack_compute_instance_v2.nomad_server.0.id}"
  fixed_ip    = "${openstack_compute_instance_v2.nomad_server.0.network.0.fixed_ip_v4}"
}


output consul-discovery-node-floating-ip {
  value = "${openstack_networking_floatingip_v2.consul_discovery_node_ip.address}"
}

output nomad-servers-fixed-ips {
  value = "${openstack_compute_instance_v2.nomad_server.*.network.0.fixed_ip_v4}"
}
