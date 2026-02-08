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
sudo dnf update -y
sudo dnf install bind-utils -y
sudo dnf install git -y
sudo dnf install tmux -y
sudo dnf install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
aws --version
