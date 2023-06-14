FROM centos:7

# utils
RUN yum install -y epel-release ca-certificates && \
    yum install -y make wget git gcc gcc-c++ curl-devel autoconf openssl-devel && \
    yum -y clean all --enablerepo='*'

# make Used to compile binary
# wget Compressed package for downloading related components
# git Used to pull the corresponding code from the code warehouse
# gcc gcc-c++ Provide C environment for compiling binary
# curl-devel curl-devel autoconf openssl-devel Used to provide basic communication services for binary system
# unused temporary...
# unzip zip which bzip2 expat-devel gettext-devel perl-devel zlib-devel

# Set the locale(en_US.UTF-8)
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# USER jenkins
WORKDIR /home/jenkins

ENV SONAR_SCANNER_VERSION 4.8.0.2856

RUN yum -y install unzip && \
    curl -o sonar_scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip sonar_scanner.zip && rm sonar_scanner.zip \
    && rm -rf sonar-scanner-$SONAR_SCANNER_VERSION-linux/jre && \
    sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /home/jenkins/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin/sonar-scanner && \
    mv /home/jenkins/sonar-scanner-$SONAR_SCANNER_VERSION-linux /usr/bin

ENV PATH $PATH:/usr/bin/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin

ENV EXCLUDE_DOCKER 0
COPY ./ ./
RUN chmod +x ./hack/install_utils.sh && ./hack/install_utils.sh && rm -rf ./*

CMD ["docker","version"]