ARG RUNTIME
ARG REGISTRY_REPO
FROM $REGISTRY_REPO/jenkins-agent-base:latest$RUNTIME

RUN yum -y groupinstall 'Development Tools'  && yum -y clean all --enablerepo='*'

ENV GOLANG_VERSION 1.17.13

ENV PATH $PATH:/usr/local/go/bin
ENV PATH $PATH:/usr/local/
ENV GOROOT /usr/local/go
ENV GOPATH=/home/jenkins/go
ENV PATH $PATH:$GOPATH/bin

COPY ./ ./

RUN chmod +x ./hack/install_utils.sh && ./hack/install_utils.sh && rm -rf ./*

RUN mkdir -p $GOPATH/bin && mkdir -p $GOPATH/src && mkdir -p $GOPATH/pkg

CMD ["go","version"]