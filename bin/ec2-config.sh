#!/bin/sh
export RegionName=ap-south-1
export OutputFormat=json

mkdir --parents .aws
tee .aws/config <<EOF
[default]
region = ${RegionName}
output = ${OutputFormat}
EOF
sudo mkdir --parents /root/.aws
sudo tee /root/.aws/config <<EOF
[default]
region = ${RegionName}
output = ${OutputFormat}
EOF
sudo apt update
sudo apt upgrade -y
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo apt install unzip -y
sudo docker swarm init
sudo usermod -aG docker ubuntu
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt-get install ./minikube_latest_amd64.deb -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
