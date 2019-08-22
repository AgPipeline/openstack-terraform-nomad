variable "env_name" {
  default = "uapipeline-dev"
}

variable "openstack_cloud" {
  default = ""
}

variable "privkey" {
  default = "~/.ssh/id_rsa"
}

variable "pool_name" {
  default = "public"
}

variable nomad_client_count {
  default = "3"
}

variable nomad_client_flavor {
  default = "medium2"
}

variable nomad_client_image {
  default = "ubuntu-18.04.raw"
}

variable nomad_client_vol_size {
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