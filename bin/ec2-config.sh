#!/bin/sh
sudo mkdir --parents /root/.aws
sudo tee /root/.aws/config <<EOF
[default]
region = ${RegionName}
output = ${OutputFormat}
EOF
sudo chmod 600 /root/.aws/config
sudo apt update
sudo apt upgrade -y
sudo apt install awscli docker.io docker-compose -y
sudo docker swarm init
sudo usermod -aG docker ubuntu
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt-get install ./minikube_latest_amd64.deb -y
