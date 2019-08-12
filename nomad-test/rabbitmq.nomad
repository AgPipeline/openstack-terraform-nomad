job "rabbitmq" {
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }

  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "broker" {
    count = 3
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "rabbitmq_container" {
      driver = "docker"

      config {
        image = "rabbitmq:3.7.17-management-alpine"
        port_map {
          endpoint = 5672
          management = 15672
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "endpoint" {}
          port "management" {}
        }
      }

      service {
        name = "rabbitmq"
        tags = ["global", "rabbitmq", "message-broker", "queue"]
        port = "endpoint"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "rabbitmq-management"
        tags = ["global", "rabbitmq", "rabbitmq-management"]
        port = "management"
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
