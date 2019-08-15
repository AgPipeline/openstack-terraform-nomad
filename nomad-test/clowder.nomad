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
        image = "jpistorius/clowder:dev"
        //        image = "nginx:1.16.0-alpine"
        port_map {
          //          http = 80
          http = 9000
        }
      }

      resources {
//        cpu    = 500
//        memory = 256
        cpu    = 50
        memory = 64
        network {
          mbits = 10
          port "http" {}
        }
      }

      template {
        data = <<EOH
          {{ with service "postgresql" }}
          {{ with index . 0 }}
          POSTGRES_IP="{{ .Address }}"
          POSTGRES_PORT="{{ .Port }}"
          {{ end }}{{ end }}
          {{ with service "mongo" }}
          {{ with index . 0 }}
          MONGO_URI="mongodb://{{ .Address }}:{{ .Port }}/clowder"
          {{ end }}{{ end }}
          {{ with service "rabbitmq" }}
          {{ with index . 0 }}
          RABBITMQ_URI="amqp://guest:guest@{{ .Address }}:{{ .Port }}/%2F"
          {{ end }}{{ end }}
          RABBITMQ_CLOWDERURL="http://{{ env "NOMAD_ADDR_http" }}"
          {{ with service "elasticsearch-rpc" }}
          {{ with index . 0 }}
          ELASTICSEARCH_RPC_IP="{{ .Address }}"
          ELASTICSEARCH_RPC_PORT="{{ .Port }}"
          {{ end }}{{ end }}
        EOH

        destination = "secrets/custom.env"
        env         = true
      }

      template {
        data = <<EOH
# START: {{ timestamp }}
application.secret="#,uXmau>8'X7bhN#uYX%cP<DAw-=dkZvxNU9cq&']3(qKUXSw[']{UYRW::Lk'Mu"
commKey="8M3wVqcAYa"
registerThroughAdmins=false
initialAdmins="admin@example.com"
smtp.mock=true
smtp.host="smtp"
service.byteStorage=services.filesystem.DiskByteStorageService
clowder.diskStorage.path="/home/clowder/data"
mongodbURI = ${MONGO_URI}
clowder.rabbitmq.uri=${RABBITMQ_URI}
clowder.rabbitmq.exchange=clowder
clowder.rabbitmq.clowderurl=${RABBITMQ_CLOWDERURL}
elasticsearchSettings.clusterName="clowder"
elasticsearchSettings.serverAddress=${ELASTICSEARCH_RPC_IP}
elasticsearchSettings.serverPort=${ELASTICSEARCH_RPC_PORT}
postgres.host=${POSTGRES_IP}
postgres.host=${POSTGRES_PORT}
# END: {{ timestamp }}
EOH

        destination = "local/custom.conf"
        env         = false
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
