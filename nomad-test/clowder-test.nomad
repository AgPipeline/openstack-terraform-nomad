job "clowder-test" {
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
    count = 3
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      sticky  = true
      migrate = true
      size    = 300
    }

    task "web_container" {
      driver = "docker"

      config {
        //        image = "clowder/clowder:1.7.1"
        image       = "jpistorius/clowder:dev"
        //        image = "nginx:1.16.0-alpine"
        port_map {
          //          http = 80
          http = 9000
        }
        extra_hosts = [
          "mylocalhost:${attr.unique.network.ip-address}",
          "nomad-host-ip:${NOMAD_IP_http}",
          "localhost:${NOMAD_IP_http}"
        ]
      }

      resources {
        cpu    = 50
        memory = 64
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "clowder-web-test"
        tags = [
          "urlprefix-/"]
        port = "http"
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
