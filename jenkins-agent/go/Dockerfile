ARG RUNTIME
ARG REGISTRY_REPO
FROM --platform=linux/amd64 $REGISTRY_REPO/build-helper:latest as build
FROM $REGISTRY_REPO/jenkins-agent-base:latest$RUNTIME

RUN yum -y groupinstall 'Development Tools'  && yum -y clean all --enablerepo='*'

ENV GOLANG_VERSION 1.17.13

ENV PATH $PATH:/usr/local/go/bin
ENV PATH $PATH:/usr/local/
ENV GOROOT /usr/local/go
ENV GOPATH=/home/jenkins/go
ENV PATH $PATH:$GOPATH/bin

COPY ./ ./

COPY --from=build /binaryfile/go1.17.13.linux-amd64 ./go1.17.13.linux-amd64
COPY --from=build /binaryfile/go1.17.13.linux-arm64 ./go1.17.13.linux-arm64

RUN chmod +x ./hack/install_utils.sh && ./hack/install_utils.sh && rm -rf ./*

RUN mkdir -p $GOPATH/bin && mkdir -p $GOPATH/src && mkdir -p $GOPATH/pkg

CMD ["go","version"]