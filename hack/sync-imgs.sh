#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

TAG=${1-"latest"}
IMAGE_MANIFEST_PATH=${2-"./imgs-manifest.list"}
SOURCE_REPO=${3-"release.daocloud.io"}
TARGET_REPO=${4-"release-ci.daocloud.io"}

manifest=$(cat ${IMAGE_MANIFEST_PATH} | sed "s/#TAG/${TAG}/g")
for img in ${manifest}
  do
    echo "skopeo: sync images: ${img} with all arch and all runtime"
    skopeo copy --insecure-policy --all docker://${SOURCE_REPO}/amamba/jenkins-agent/${img} docker://${TARGET_REPO}/amamba/jenkins-agent/${img}
    skopeo copy --insecure-policy --all docker://${SOURCE_REPO}/amamba/jenkins-agent/${img}-podman docker://${TARGET_REPO}/amamba/jenkins-agent/${img}-podman
  done
