#!/bin/sh
export RegionName=ap-south-1
export OutputFormat=json

mkdir --parents .aws
tee .aws/config <<EOF
[default]
region = ${RegionName}
output = ${OutputFormat}
EOF
sudo apt update
sudo apt upgrade -y
sudo apt install awscli -y
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo docker swarm init
sudo usermod -aG docker ubuntu
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt-get install ./minikube_latest_amd64.deb -y
