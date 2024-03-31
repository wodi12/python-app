#!/bin/bash

# install jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# install docker
sudo yum install docker -y
sudo usermod -a -G docker $USER
sudo usermod -a -G jenkins docker
newgrp docker
sudo systemctl start docker
sudo systemctl enable docker

# install terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 381492292155.dkr.ecr.us-east-2.amazonaws.com
# docker pull 381492292155.dkr.ecr.us-east-2.amazonaws.com/hello-world
# docker run 381492292155.dkr.ecr.us-east-2.amazonaws.com/hello-world