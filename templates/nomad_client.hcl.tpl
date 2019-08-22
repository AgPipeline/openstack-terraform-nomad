client {
  enabled = true
  servers = [%{ for host in NOMAD_HOSTS ~}"${host}:4647", %{ endfor ~}]
}