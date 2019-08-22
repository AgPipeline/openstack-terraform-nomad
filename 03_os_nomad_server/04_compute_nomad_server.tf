resource "openstack_compute_servergroup_v2" "consul_nomad_server_group" {
  name     = "consul-nomad-servers"
  policies = ["soft-anti-affinity"]
}

resource "openstack_compute_instance_v2" "nomad_server" {
  count             = var.nomad_server_count
  name              = "${var.env_name}-nomad_server${count.index}"
  flavor_name       = var.nomad_server_flavor
  key_pair          = data.openstack_compute_keypair_v2.terraform.name
  user_data         = templatefile("../templates/install_consul_nomad.sh.tpl",
  {
    CONSUL_VERSION = var.consul_version,
    NOMAD_VERSION  = var.nomad_version,
    CONSUL_MASTER_TOKEN = var.consul_master_token,
    NOMAD_SERVER_COUNT = var.nomad_server_count
    IS_SERVER = true
  }
  )

  scheduler_hints {
    group             = openstack_compute_servergroup_v2.consul_nomad_server_group.id
  }

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
    openstack_compute_secgroup_v2.consul_server.name,
    openstack_compute_secgroup_v2.nomad_server.name,
    "default",
  ]

  depends_on = [
    data.openstack_networking_subnet_v2.subnet_1
  ]
}

output nomad-servers-fixed-ips {
  value = "${openstack_compute_instance_v2.nomad_server.*.network.0.fixed_ip_v4}"
}

resource "null_resource" "consul_cluster" {
  count    = length(openstack_compute_instance_v2.nomad_server)
  # Changes to any of the IP addresses of the OTHER instances of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ips = join(" ", [for s in "${openstack_compute_instance_v2.nomad_server.*.network.0.fixed_ip_v4}" : s if s != openstack_compute_instance_v2.nomad_server[count.index].network[0].fixed_ip_v4])
  }

  connection {
    host                = openstack_compute_instance_v2.nomad_server[count.index].network.0.fixed_ip_v4
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
      CONSUL_HOSTS = [for s in "${openstack_compute_instance_v2.nomad_server.*.network.0.fixed_ip_v4}" : s if s != openstack_compute_instance_v2.nomad_server[count.index].network[0].fixed_ip_v4]
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
      "until [ ! -z \"$(systemctl list-unit-files | grep consul.service | grep enabled)\" ]; do echo \"No consul service yet\"; sleep 5; done",
      "sudo systemctl reload consul",
      "until [ ! -z \"$(systemctl list-unit-files | grep nomad.service | grep enabled)\" ]; do echo \"No nomad service yet\"; sleep 5; done"
    ]
    on_failure = "fail"
  }
}
