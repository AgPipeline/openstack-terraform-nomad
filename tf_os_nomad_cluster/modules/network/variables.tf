variable "openstack_cloud" {
  type = "string"

  description = <<EOF
OpenStack cloud name
EOF
}

variable "count_ips" {
  type = "string"

  description = <<EOF
Number of IPs to provision.
EOF
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
