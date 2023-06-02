#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -x

wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install ${NODEVERSION}
ln -s /root/.nvm/versions/node/${NODEVERSION}/bin/node /usr/local/bin/node
ln -s /root/.nvm/versions/node/${NODEVERSION}/bin/npm /usr/local/bin/npm
ls -al /usr/local/bin/node
ls -al /usr/local/bin/npm
node -v
npm -v