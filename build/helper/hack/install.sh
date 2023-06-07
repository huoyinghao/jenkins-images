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
