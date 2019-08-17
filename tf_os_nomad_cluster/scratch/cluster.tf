module "nomad_cluster" {
  source = "../modules/nomad_cluster"

  public_key_file    = var.pubkey
//  private_key_file   = var.privkey
  ssh_key_pair_name  = "${var.env_name}-key_pair"
  openstack_cloud    = var.openstack_cloud
//  do_bootstrap       = var.nomad_cluster_do_bootstrap
  //  consul_join_params = var.consul_join_params
  //  nomad_bin_url      = var.nomad_bin_url
  cluster_size       = var.nomad_server_count
  //  region             = var.region
  image_name         = var.nomad_image_name
  flavor_name        = var.nomad_server_flavor
  security_group_ids = var.nomad_server_security_group_ids
  network_id         = var.nomad_network_id
//  consul_version     = var.nomad_consul_version
  env_name_prefix    = var.env_name
  app_name           = var.nomad_app_name
}