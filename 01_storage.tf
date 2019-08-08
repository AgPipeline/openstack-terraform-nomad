resource "openstack_blockstorage_volume_v2" "postgresql_data" {
  name = "${var.env_name}-postgresql-data"
  size = "${var.postgresql_volume_size}"
}

resource "openstack_blockstorage_volume_v2" "mongo_data" {
  count = "${var.mongo_count}"
  name  = "${var.env_name}-mongo-data${count.index}"
  size  = "${var.mongo_volume_size}"
}
