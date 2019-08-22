datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "${CONSUL_MASTER_TOKEN}"
retry_join = [%{ for host in CONSUL_HOSTS ~}"${host}", %{ endfor ~}]
performance {
  raft_multiplier = 1
}