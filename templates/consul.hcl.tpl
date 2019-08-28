datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "${CONSUL_MASTER_TOKEN}"
retry_join = [%{ for host in CONSUL_HOSTS ~}"${host}", %{ endfor ~}]
bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"192.168.0.0/24\" | attr \"address\" }}"
client_addr = "0.0.0.0"
performance {
  raft_multiplier = 1
}