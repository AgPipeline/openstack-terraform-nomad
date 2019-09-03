job "rabbitmq" {
  datacenters = [
    "dc1"]
  type        = "service"

  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = false
    canary            = 0
  }

  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "broker" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      sticky  = true
      migrate = true
      size    = 32768
    }

    task "rabbitmq_container" {
      driver = "docker"

      config {
        image = "rabbitmq:3.7.17-management-alpine"
        port_map {
          endpoint   = 5672
          management = 15672
        }

        extra_hosts = [
          "mylocalhost:${attr.unique.network.ip-address}",
          "nomad-host-ip:${NOMAD_IP_endpoint}",
          "rabbitmq:${NOMAD_IP_endpoint}"
        ]
      }

      resources {
        cpu    = 2000
        memory = 4096
        network {
          mbits = 10
          port "endpoint" {}
          port "management" {}
        }
      }

      service {
        name = "rabbitmq"
        port = "endpoint"
        check {
          name         = "alive"
          type         = "tcp"
          interval     = "10s"
          timeout      = "2s"
          address_mode = "driver"
          port         = 5672
        }

        tags = [
          "urlprefix-:5672 proto=tcp"
        ]
      }

      service {
        name = "rabbitmq-management"
        port = "management"
        check {
          name         = "alive"
          type         = "http"
          path         = "/"
          interval     = "10s"
          timeout      = "2s"
          address_mode = "driver"
          port         = 15672
        }

        tags = [
          "urlprefix-:15672 proto=tcp"
        ]
      }
    }
  }
}
