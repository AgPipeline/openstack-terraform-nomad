job "elasticsearch" {
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

  group "index" {
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

    task "elasticsearch_container" {
      driver = "docker"

      config {
        image   = "elasticsearch:2"
        command = "elasticsearch"
        args    = [
          "-Des.cluster.name=clowder"
        ]
        port_map {
          // https://discuss.elastic.co/t/elasticsearch-port-9200-or-9300/72080
          http = 9200
          rpc  = 9300
        }
      }

      resources {
        cpu    = 2000
        memory = 4096
        network {
          mbits = 10
          port "http" {}
          port "rpc" {}
        }
      }

      service {
        name = "elasticsearch-rest"
        port = "http"
        check {
          name         = "es-rest-health"
          type         = "http"
          path         = "/_cat/health?h=status"
          interval     = "10s"
          timeout      = "2s"
          address_mode = "driver"
          port         = 9200
        }

        tags = [
          "urlprefix-:9200 proto=tcp"
        ]
      }

      service {
        name = "elasticsearch-rpc"
        port = "rpc"

        check {
          name     = "es-rpc-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [
          "urlprefix-:9300 proto=tcp"
        ]
      }
    }
  }
}