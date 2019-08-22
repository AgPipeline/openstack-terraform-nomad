client {
  enabled = true
  servers = [%{ for host in NOMAD_SERVER_HOSTS ~}"${host}:4647", %{ endfor ~}]
}