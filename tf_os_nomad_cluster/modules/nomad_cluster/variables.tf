variable "openstack_cloud" {
  type = "string"

  description = <<EOF
OpenStack cloud name
EOF
}

variable "cluster_size" {
  type = "string"

  description = <<EOF
Number of nomad instances for cluster.  Should be an odd number for quorum.
EOF
}

variable "region" {
  type = "string"
  default = ""
}

variable "security_group_ids" {
  type = "list"

  description = <<EOF
OS Security Groups ID's.
EOF
}

variable "network_id" {
  type = "string"

  description = <<EOF
OS Network ID.
EOF
}

variable "env_name_prefix" {
  type = "string"

  description = <<EOF
Prefix for environment to use on IP names.
EOF
}

variable "app_name" {
  type = "string"

  description = <<EOF
App name to use in IP names.  IP Name will follow the pattern [environment]-[app]-[sequence]"
EOF
}

variable "ssh_key_pair_name" {
}

variable "public_key_file" {
}

variable "image_name" {
}

variable "flavor_name" {
}
