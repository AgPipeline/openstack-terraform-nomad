resource "openstack_compute_servergroup_v2" "consul_nomad_client_group" {
  name     = "consul-nomad-clients"
  policies = ["soft-anti-affinity"]
}

resource "openstack_compute_instance_v2" "nomad_client" {
  count             = var.nomad_client_count
  name              = "${var.env_name}-nomad_client${count.index}"
  flavor_name       = var.nomad_client_flavor
  key_pair          = data.openstack_compute_keypair_v2.terraform.name
  user_data         = templatefile("../templates/install_consul_nomad.sh.tpl",
  {
    CONSUL_VERSION = var.consul_version,
    NOMAD_VERSION  = var.nomad_version,
    CONSUL_MASTER_TOKEN = var.consul_master_token,
    NOMAD_SERVER_COUNT = length(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips)
    IS_SERVER = false
    NOMAD_SERVER_HOSTS = flatten(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips)
    CONSUL_HOSTS = flatten(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips)
  }
  )

  scheduler_hints {
    group             = openstack_compute_servergroup_v2.consul_nomad_client_group.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.nomad_client_image.id
    source_type           = "image"
    volume_size           = var.nomad_client_vol_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "${var.env_name}-net"
  }

  security_groups = [
    openstack_compute_secgroup_v2.consul_client.name,
    openstack_compute_secgroup_v2.nomad_client.name,
    "default",
  ]

  depends_on = [
    data.openstack_networking_subnet_v2.subnet_1
  ]
}

output nomad-clients-fixed-ips {
  value = "${openstack_compute_instance_v2.nomad_client.*.network.0.fixed_ip_v4}"
}

resource "null_resource" "update_consul_cluster_for_client" {
  count    = var.nomad_client_count
  triggers = {
    cluster_instance_ips = join(" ", flatten(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips))
  }

  lifecycle {
    create_before_destroy = true
  }

  connection {
    host                = openstack_compute_instance_v2.nomad_client[count.index].network.0.fixed_ip_v4
    agent               = "true"
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file(var.privkey)
    bastion_host        = data.openstack_networking_floatingip_v2.bastion_ip.address
    bastion_private_key = file(var.privkey)
  }

  provisioner "file" {
    content         = templatefile("../templates/consul.hcl.tpl",
    {
      CONSUL_MASTER_TOKEN = var.consul_master_token,
      CONSUL_HOSTS = flatten(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips)
    }
    )
    destination     = "/home/ubuntu/consul.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      "until [ -e /etc/consul.d/consul.hcl ]; do echo \"/etc/consul.d/consul.hcl doesn't exist as of yet...\"; sleep 5; done",
      "until [ ! -z \"$(grep consul /etc/passwd)\" ]; do echo \"No consul user yet\"; sleep 5; done",
      "sudo mv /home/ubuntu/consul.hcl /etc/consul.d/consul.hcl",
      "sudo chmod 640 /etc/consul.d/consul.hcl",
      "sudo chown consul:consul /etc/consul.d/consul.hcl",
    ]
  }

  provisioner "file" {
    content         = templatefile("../templates/nomad_client.hcl.tpl",
    {
      NOMAD_SERVER_HOSTS = flatten(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips)
    }
    )
    destination     = "/home/ubuntu/nomad_client.hcl"
  }

  provisioner "remote-exec" {
    inline = concat(
      [
        "sudo mkdir -p /etc/nomad.d/",
        "sudo mv /home/ubuntu/nomad_client.hcl /etc/nomad.d/client.hcl",
        "until [ ! -z \"$(systemctl list-unit-files | grep nomad.service | grep enabled)\" ]; do echo \"No nomad service yet\"; sleep 5; done"
      ],
      formatlist("nomad node config -update-servers \"%s:4647\"", flatten(data.openstack_networking_port_v2.consul_server_port.*.all_fixed_ips))
    )
  }
}
