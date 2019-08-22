#!/usr/bin/env bash

# See: https://learn.hashicorp.com/consul/datacenter-deploy/deployment-guide

mkdir --parents /etc/consul.d
touch /etc/consul.d/consul.hcl
chmod 640 /etc/consul.d/consul.hcl

(cat <<-EOF
datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "${CONSUL_MASTER_TOKEN}"
# retry_join = ["127.0.0.1"]
performance {
  raft_multiplier = 1
}
EOF
) > /etc/consul.d/consul.hcl

useradd --system --home /etc/consul.d --shell /bin/false consul
chown --recursive consul:consul /etc/consul.d

mkdir --parents /etc/consul.d
touch /etc/consul.d/server.hcl
chown --recursive consul:consul /etc/consul.d
chmod 640 /etc/consul.d/server.hcl

%{ if IS_SERVER == true }
(cat <<-EOF
server = true
bootstrap_expect = ${NOMAD_SERVER_COUNT}
ui = true
EOF
) > /etc/consul.d/server.hcl
%{ else }
(cat <<-EOF
server = false
ui = true
EOF
) > /etc/consul.d/server.hcl
%{ endif }

apt-get update
apt-get install -y unzip

%{ if IS_SERVER == false}
echo "Installing Docker..."
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
sudo apt-get update
sudo apt-get install -y docker-ce
# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart
# TODO: Should we add the nomad user to the docker group?
sudo usermod -aG docker ubuntu
sudo docker --version
%{ endif }

curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

unzip consul_${CONSUL_VERSION}_linux_amd64.zip
chown root:root consul
mv consul /usr/local/bin/
consul --version

consul -autocomplete-install
complete -C /usr/local/bin/consul consul

mkdir --parents /opt/consul
chown --recursive consul:consul /opt/consul

touch /etc/systemd/system/consul.service

(cat <<-EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
) > /etc/systemd/system/consul.service

systemctl enable consul
systemctl start consul
systemctl status consul


echo "Installing Nomad..."
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
chown root:root nomad
mv nomad /usr/local/bin/
nomad version

nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad
mkdir --parents /opt/nomad

touch /etc/systemd/system/nomad.service
(cat <<-EOF
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=10

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
) > /etc/systemd/system/nomad.service


# Common configuration
mkdir --parents /etc/nomad.d
chmod 700 /etc/nomad.d
touch /etc/nomad.d/nomad.hcl
(cat <<-EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
EOF
) > /etc/nomad.d/nomad.hcl

%{ if IS_SERVER == true }
# Server configuration
touch /etc/nomad.d/server.hcl
(cat <<-EOF
server {
  enabled = true
  bootstrap_expect = ${NOMAD_SERVER_COUNT}
}
EOF
) > /etc/nomad.d/server.hcl
%{ else }
# Client configuration
touch /etc/nomad.d/client.hcl
(cat <<-EOF
client {
  enabled = true
}
EOF
) > /etc/nomad.d/client.hcl
%{ endif }

systemctl enable nomad
systemctl start nomad
systemctl status nomad