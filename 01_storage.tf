resource "openstack_blockstorage_volume_v2" "postgresql" {
  name = "${var.env_name}-postgresql"
  size = "${var.postgresql_volume_size}"
}
