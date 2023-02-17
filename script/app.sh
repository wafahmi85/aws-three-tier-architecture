#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo docker run --restart always -p 8080:8080 -e MYSQL_HOST="db.solution.com" -e MYSQL_USER="admin" -e MYSQL_PASS=12345qwert wafahmi/simple_node



# Reference from https://www.geeksforgeeks.org/check-if-node-js-mysql-server-is-active-or-not/