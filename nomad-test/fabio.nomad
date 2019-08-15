job "fabio" {
  datacenters = [
    "dc1"]
  type        = "system"

  group "fabio" {
    count = 1
    task "fabio" {
      driver = "docker"
      config {
        image        = "fabiolb/fabio"
        network_mode = "host"
        args         = [
          "-proxy.addr",
          ":5432;proto=tcp"]
      }

      resources {
        cpu    = 200
        memory = 128
        network {
          mbits = 20
          port "lb" {
            static = 9999
          }
          port "ui" {
            static = 9998
          }
          port "postgresql_proxy" {
            static = 5432
          }
        }
      }
    }
  }
}