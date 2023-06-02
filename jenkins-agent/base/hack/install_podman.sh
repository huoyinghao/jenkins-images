#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -x

ARCH=$(uname -m)
echo $ARCH
# Podman
echo "Installing podman"
if [[ ${ARCH} == 'x86_64' ]]; then
  curl -L -o /etc/yum.repos.d/home:alvistack.repo https://download.opensuse.org/repositories/home:alvistack/CentOS_7/home:alvistack.repo && \
  yum -y install podman fuse-overlayfs && \
  ln -s /usr/bin/podman /usr/bin/docker && \
  yum -y clean all --enablerepo='*'
elif [[ ${ARCH} == 'aarch64' ]]; then
  curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_7/devel:kubic:libcontainers:stable.repo && \
  yum -y install podman fuse-overlayfs && \
  ln -s /usr/bin/podman /usr/bin/docker && \
  yum -y clean all --enablerepo='*'
else
  echo "do not support this arch"
  exit 1
fi