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
          "-proxy.addr", ":9999,:5432;proto=tcp,:5672;proto=tcp,:9000;proto=tcp,:9200;proto=tcp,:9300;proto=tcp,:15672;proto=tcp,:27017;proto=tcp",
          "-log.access.target", "stdout"
        ]
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
          port "rabbitmq_proxy" {
            static = 5672
          }
          port "clowder_web_proxy" {
            static = 9000
          }
          port "elasticsearch_rest_proxy" {
            static = 9200
          }
          port "elasticsearch_rpc_proxy" {
            static = 9300
          }
          port "rabbitmq_mgmt_proxy" {
            static = 15672
          }
          port "mongo_proxy" {
            static = 27017
          }
        }
      }
    }
  }
}