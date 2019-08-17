provider "openstack" {
  # assumes OS environment variables
  cloud = "${ var.openstack_cloud }"
}

resource "openstack_networking_port_v2" "nomad_ips" {
  count = "${ var.count_ips }"
  name = "${ var.env_name_prefix }-${ var.app_name }-${ count.index+1 }"
  security_group_ids = "${ var.security_group_ids }"
  network_id = "${ var.network_id }"
  admin_state_up = "true"

#  lifecycle {
#    create_before_destroy = true
#  }
}
