variable "env_name" {
  default = "uapipeline-dev"
}

variable "openstack_cloud" {
  default = ""
}

variable "pubkey" {
  default = "~/.ssh/id_rsa.pub"
}

variable "privkey" {
  default = "~/.ssh/id_rsa"
}

variable "bastion_flavor" {
  default = "tiny1"
}

variable "bastion_image" {
  default = "ubuntu-18.04.raw"
}

variable "postgresql_flavor" {
  default = "medium1"
}

variable "postgresql_image" {
  default = "ubuntu-18.04.raw"
}

variable "postgresql_volume_size" {
  default = "600"
}

variable "mongo_flavor" {
  default = "medium1"
}

variable "mongo_image" {
  default = "ubuntu-18.04.raw"
}

variable "mongo_volume_size" {
  default = "600"
}

variable "mongo_count" {
  default = "3"
}

variable "mongo_opsmanager_flavor" {
  default = "medium1"
}

variable "mongo_opsmanager_image" {
  default = "ubuntu-18.04.raw"
}

variable "mongo_opsmanager_volume_size" {
  default = "2000"
}

variable "external_network_name" {
  default = "public"
}

variable "pool_name" {
  default = "public"
}

variable "availability_zone" {
  default = ""
}

variable "dns_nameservers" {
  description = "An array of DNS name server names used by hosts in this subnet."
  type        = "list"
  default     = []
}

variable "bastion_allowed_cidr" {
  description = "A CIDR range of IP addresses which are allowed to SSH to the bastion host."
  default     = "0.0.0.0/0"
}
