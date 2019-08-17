provider "openstack" {
  cloud = "${ var.openstack_cloud }"
}

module "nomad_network" {
  source = "../network"

  openstack_cloud = "${ var.openstack_cloud }"
  count_ips = "${ var.cluster_size }"
  security_group_ids = "${ var.security_group_ids }"
  network_id = "${ var.network_id }"
  env_name_prefix = "${ var.env_name_prefix }"
  app_name = var.app_name
}

resource "openstack_compute_keypair_v2" "keypair" {
  name = "${ var.env_name_prefix}-${ var.ssh_key_pair_name }"
  public_key = "${ file(var.public_key_file) }"
}

resource "openstack_compute_instance_v2" "nomad_cluster" {
  depends_on = [ "module.nomad_network" ]
  count = var.cluster_size
  name = "${ var.env_name_prefix }-nomad-svr-${ count.index + 1 }"
  region = var.region
  image_name = var.image_name
  flavor_name = var.flavor_name
  key_pair = "${ var.env_name_prefix}-${ var.ssh_key_pair_name }"

//  network {
//    port = "${ module.nomad_network.ports[count.index] }"
//  }

//  connection {
//    agent = "true"
//    type = "ssh"
//    host = "${ module.nomad_network.all_fixed_ips[count.index] }"
//    user = "core"
//    private_key = "${ file(var.private_key_file) }"
//  }

//  provisioner "file" {
//    content = "${ data.template_file.server-config.*.rendered[count.index] }"
//    destination = "/tmp/server.conf"
//  }

//  provisioner "file" {
//    content = "${ data.template_file.server-bootstrap-config.*.rendered[count.index] }"
//    destination = "/tmp/server-bootstrap.conf"
//  }

//  provisioner "remote-exec" {
//    inline = [
//      "sudo mkdir /etc/nomad",
//      "sudo cp /tmp/server.conf /etc/nomad/",
//      "sudo cp /tmp/server-bootstrap.conf /etc/nomad/",
//      "sudo chown -R root /etc/nomad",
//      "curl -s ${var.nomad_bin_url} > /tmp/nomad.zip",
//      "sudo mkdir -p /var/lib/nomad/data",
//      "sudo mkdir -p /opt/bin",
//      "sudo unzip /tmp/nomad.zip -d /opt/bin/",
//      "sudo /opt/bin/nomad agent -config=/etc/nomad/server-bootstrap.conf &",
//      "${ data.template_file.cluster_health.rendered }",
//      "sudo pkill nomad",
//      "sudo systemctl start nomad"
//    ]
//  }

  /* recommended to prevent quorum loss
    lifecycle {
      prevent_destroy = true
    }
  */

//  user_data = "${ data.template_file.cloud-config.*.rendered[count.index] }"
}
