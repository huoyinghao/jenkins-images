FROM centos:7

# utils
RUN yum install -y epel-release ca-certificates && \
    yum install -y make wget git gcc gcc-c++ curl-devel autoconf openssl-devel && \
    yum -y clean all --enablerepo='*' && \
    yum update

# make Used to compile binary
# wget Compressed package for downloading related components
# git Used to pull the corresponding code from the code warehouse
# gcc gcc-c++ Provide C environment for compiling binary
# curl-devel curl-devel autoconf openssl-devel Used to provide basic communication services for binary system
# unused temporary...
# unzip zip which bzip2 expat-devel gettext-devel perl-devel zlib-devel

# Set the locale(en_US.UTF-8)

# https://github.com/CentOS/sig-cloud-instance-images/issues/71
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV SONAR_SCANNER_VERSION 4.8.0.2856
ENV PATH /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/bin:$PATH
# USER jenkins
WORKDIR /home/jenkins

RUN yum -y install unzip && \
    curl -Lo sonar_scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip && \
    unzip sonar_scanner.zip && rm sonar_scanner.zip && \
    mv /home/jenkins/sonar-scanner-${SONAR_SCANNER_VERSION} /opt/sonar-scanner-${SONAR_SCANNER_VERSION}

ENV EXCLUDE_DOCKER 0

COPY ./ ./
RUN chmod +x ./hack/install_utils.sh && ./hack/install_utils.sh && rm -rf ./*
RUN sed -i '1 a JAVA_HOME=/opt/java-11.0.14' /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner
RUN sonar-scanner --version
CMD ["docker","version"]