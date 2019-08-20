data "openstack_networking_network_v2" "external" {
  name = "${var.external_network_name}"
}

data "openstack_images_image_v2" "nomad_server_image" {
  name        = var.nomad_server_image
  most_recent = true

  properties = {
    key = "value"
  }
}

data "openstack_images_image_v2" "nomad_client_image" {
  name        = var.nomad_client_image
  most_recent = true

  properties = {
    key = "value"
  }
}