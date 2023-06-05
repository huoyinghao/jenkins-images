#!/usr/bin/bash

set -o errexit
set -o nounset
set -x
set -e

GO_VERSION="1.17.13"
MAVEN_VERSION=3.5.3

apt-get update -y && apt-get upgrade -y
apt-get install -y wget

echo "installing necessary components"
# install go and maven
wget https://golang.google.cn/dl/go$GO_VERSION.linux-amd64.tar.gz && tar -xvf go$GO_VERSION.linux-amd64.tar.gz && mv go go$GO_VERSION.linux-amd64 && rm -rf go$GO_VERSION.linux-amd64.tar.gz
wget https://golang.google.cn/dl/go$GO_VERSION.linux-arm64.tar.gz && tar -xvf go$GO_VERSION.linux-arm64.tar.gz && mv go go$GO_VERSION.linux-arm64 && rm -rf go$GO_VERSION.linux-arm64.tar.gz
wget https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && tar -xvf apache-maven-$MAVEN_VERSION-bin.tar.gz && rm -rf apache-maven-$MAVEN_VERSION-bin.tar.gz
# install docker
wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.2.tgz && tar -zxvf docker-24.0.2.tgz && mv docker docker-amd64
wget https://download.docker.com/linux/static/stable/aarch64/docker-24.0.2.tgz && tar -zxvf docker-24.0.2.tgz && mv docker docker-arm64
# install helm & helm3
wget https://get.helm.sh/helm-v2.11.0-linux-amd64.tar.gz && tar -zxvf helm-v2.11.0-linux-amd64.tar.gz -C helm2-amd64
wget https://get.helm.sh/helm-v3.5.0-linux-amd64.tar.gz && tar -zxvf helm-v3.5.0-linux-amd64.tar.gz -C helm3-amd64
wget https://get.helm.sh/helm-v2.11.0-linux-arm64.tar.gz && tar -zxvf helm-v2.11.0-linux-arm64.tar.gz -C helm2-arm64
wget https://get.helm.sh/helm-v3.5.0-linux-arm64.tar.gz && tar -zxvf helm-v3.5.0-linux-arm64.tar.gz -C helm3-arm64
# install kubectl
wget https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl kubectl-amd64
wget https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/arm64/kubectl && chmod +x kubectl && mv kubectl kubectl-arm64
