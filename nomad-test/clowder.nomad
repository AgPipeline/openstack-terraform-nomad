job "clowder" {
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

  group "web" {
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
      size    = 4096
    }

    task "web_container" {
      driver = "docker"

      config {
//        image = "clowder/clowder:1.7.1"
        image = "jpistorius/clowder:dev"
        //        image = "nginx:1.16.0-alpine"
        port_map {
          //          http = 80
          http = 9000
        }

        extra_hosts = [
          "mylocalhost:${attr.unique.network.ip-address}",
          "nomad-host-ip:${NOMAD_IP_http}",
          "localhost:${NOMAD_IP_http}",
          "clowder:${NOMAD_IP_http}",
          "rabbitmq:${NOMAD_IP_http}",
          "mongo:${NOMAD_IP_http}",
          "elasticsearch:${NOMAD_IP_http}"
        ]

        volume_driver = "local"

        volumes = [
          "clowder-custom:/home/clowder/custom",
          "clowder-data:/home/clowder/data"
        ]
      }

      resources {
        cpu    = 6000
        memory = 2048
//        cpu    = 50
//        memory = 64
        network {
          mbits = 10
          port "http" {}
        }
      }


      service {
        name = "web"
        tags = ["urlprefix-/"]
        port = "http"
//        check {
//          name     = "alive"
//          type     = "script"
//          command  = "/home/clowder/healthcheck.sh"
//          interval = "30s"
//          timeout  = "5s"
//        }
        check {
          name     = "tcp-check"
          port     = "http"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
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
