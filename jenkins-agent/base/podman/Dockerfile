ARG REGISTRY_REPO
FROM  $REGISTRY_REPO/jenkins-agent-base:latest

RUN rm -rf /usr/bin/docker
# Install podman
COPY ./ ./
RUN chmod +x ./hack/install_podman.sh && ./hack/install_podman.sh

COPY storage.conf /etc/containers/storage.conf

COPY containers.conf /etc/containers/containers.conf

COPY registries.conf /etc/containers/registries.conf

VOLUME /var/lib/containers

CMD ["podman", "info"]