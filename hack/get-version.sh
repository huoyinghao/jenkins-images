#!/usr/bin/env bash

set -e

CUR_DIR=$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)

if ! command -v jq &>/dev/null; then
    tmp=$(mktemp -d)
    pushd ${tmp}
    wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
    chmod +x ./jq
    mv jq /usr/bin
    popd
fi
jq .$1 ${CUR_DIR}/../versions.json -r
