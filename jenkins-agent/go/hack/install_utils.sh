#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -x

ARCH=$(uname -m)
GO_VERSION="1.20.5"
# GOLANG
if [[ ${ARCH} == 'x86_64' ]]; then
  wget https://golang.google.cn/dl/go$GO_VERSION.linux-amd64.tar.gz
  tar -xvf go$GO_VERSION.linux-amd64.tar.gz
  rm -rf go$GO_VERSION.linux-amd64.tar.gz
  mv go /usr/local/go
elif [[ ${ARCH} == 'aarch64' ]]
then
  wget https://golang.google.cn/dl/go$GO_VERSION.linux-arm64.tar.gz
  tar -xvf go$GO_VERSION.linux-arm64.tar.gz
  rm -rf go$GO_VERSION.linux-arm64.tar.gz
  mv go /usr/local/go
else
  echo "do not support this arch"
  exit 1
fi