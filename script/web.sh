#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras enable epel
sudo yum install epel-release -y
sudo yum install nginx -y
wget https://raw.githubusercontent.com/wafahmi85/aws-three-tier-architecture/main/script/nginx.conf
sudo rm -rf /etc/nginx/nginx.conf
sudo cp nginx.conf /etc/nginx/
sudo systemctl enable nginx
sudo systemctl start nginx