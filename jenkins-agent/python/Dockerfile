ARG RUNTIME
ARG REGISTRY_REPO
FROM $REGISTRY_REPO/jenkins-agent-base:latest$RUNTIME

# python3
RUN rm -rf /etc/yum.repos.d/home* && yum clean all && yum -y install python3 && python3 -m pip install --upgrade pip && rm -rf /usr/bin/python && cp /usr/bin/python3 /usr/bin/python

CMD ["python","--version"]
