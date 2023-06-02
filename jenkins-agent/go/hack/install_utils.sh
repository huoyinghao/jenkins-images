#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -x

ARCH=$(uname -m)

# GOLANG
if [[ ${ARCH} == 'x86_64' ]]; then
  mv go1.17.13.linux-amd64 /usr/local/go && rm -rf go1.17.13.linux-arm64
elif [[ ${ARCH} == 'aarch64' ]]
then
  mv go1.17.13.linux-arm64 /usr/local/go && rm -rf go1.17.13.linux-amd64
else
  echo "do not support this arch"
  exit 1
fi