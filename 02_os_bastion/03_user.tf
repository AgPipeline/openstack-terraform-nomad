resource "openstack_compute_keypair_v2" "terraform" {
  name       = "${var.env_name}-tf-key_pair"
  public_key = "${file(var.pubkey)}"
}
