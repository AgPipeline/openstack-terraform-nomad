variable "env_name" {
  default = "uapipeline-dev"
}

variable "openstack_cloud" {
  default = ""
}

variable "external_network_name" {
  default = "public"
}

variable "pool_name" {
  default = "public"
}

variable "allowed_cidr" {
  description = "A CIDR range of IP addresses which are allowed to SSH to the bastion host."
  default     = "0.0.0.0/0"
}

variable "pubkey" {
  default = "~/.ssh/id_rsa.pub"
}

variable "flavor" {
  default = "tiny1"
}

variable "image" {
  default = "ubuntu-18.04.raw"
}
