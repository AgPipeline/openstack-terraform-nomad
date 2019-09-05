job "bin2tif" {
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

  group "extractor" {
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

    task "bin2tif_task" {
      driver = "docker"

      config {
        image = "terraref/ext-stereorgb-bin2tif:1.3"

        port_map {
          http = 9000
        }

        extra_hosts = [
          "mylocalhost:${attr.unique.network.ip-address}",
          "nomad-host-ip:${NOMAD_IP_http}",
          "clowder:${NOMAD_IP_http}",
          "rabbitmq:${NOMAD_IP_http}",
          "mongo:${NOMAD_IP_http}",
          "elasticsearch:${NOMAD_IP_http}"
        ]
        volumes     = [
          "sensor-metadata/sensor-metadata-master:/home/extractor/sites/ua-mac/sensor-metadata"
        ]
      }

      artifact {
        source      = "https://github.com/terraref/sensor-metadata/archive/master.zip"
        destination = "sensor-metadata"

        options {
          checksum = "md5:9562ab56309e8f796d52cb38cf14c3b9"
        }
      }

      template {
        data = <<EOH
# Environment variables required to work:
{{key "service/bin2tif/environment"}}
EOH
        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu    = 1000
        memory = 2048
        network {
          mbits = 10
          port "http" {}
        }
      }
    }
  }
}
