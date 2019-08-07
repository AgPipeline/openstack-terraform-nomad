resource "openstack_blockstorage_volume_v2" "postgresql" {
  name = "${var.env_name}-postgresql"
  size = "${var.postgresql_volume_size}"
}

resource "openstack_blockstorage_volume_v2" "mongo" {
  count = "${var.mongo_count}"
  name = "${var.env_name}-mongo${count.index}"
  size = "${var.mongo_volume_size}"
}
