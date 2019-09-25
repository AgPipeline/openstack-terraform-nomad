variable "env_name" {
  default = "uapipeline-dev"
}

variable "openstack_cloud" {
  default = ""
}

variable "pool_name" {
  default = "public"
}

variable "privkey" {
  default = "~/.ssh/id_rsa"
}

variable nomad_server_count {
  default = "3"
}

variable nomad_server_flavor {
  default = "medium2"
}

variable nomad_server_image {
  default = "ubuntu-18.04.raw"
}

variable nomad_server_vol_size {
  default = "100"
}

variable consul_master_token {
  default = "_consul_master_token_"
}

variable consul_version {
  type    = "string"
  default = "1.5.3"
}

variable nomad_version {
  type    = "string"
  default = "0.9.4"
}