ARG RUNTIME
ARG REGISTRY_REPO
FROM $REGISTRY_REPO/amamba/jenkins-agent/builder-base:latest$RUNTIME
COPY ./ ./
ARG VERSION
ENV NODEVERSION $VERSION

RUN chmod +x ./hack/install_utils.sh && ./hack/install_utils.sh