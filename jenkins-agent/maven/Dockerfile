ARG RUNTIME
ARG REGISTRY_REPO
FROM $REGISTRY_REPO/jenkins-agent-base:latest$RUNTIME

# java
ENV JAVA_VERSIOIN 1.8.0
RUN yum install -y java-${JAVA_VERSIOIN}-openjdk-devel \
    java-${JAVA_VERSIOIN}-openjdk-devel.i686

# maven
ENV MAVEN_VERSION 3.5.3
RUN cd /opt && wget https://archive.apache.org/dist/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz && tar -xvf apache-maven-3.5.3-bin.tar.gz && rm -rf apache-maven-3.5.3-bin.tar.gz
ENV M2_HOME /opt/apache-maven-$MAVEN_VERSION
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSIOIN}-openjdk
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH:$JAVA_HOME/bin

# ant
#ENV ANT_VERSION 1.10.7
#COPY --from=build /binaryfile/apache-ant-1.10.7 ./apache-ant-1.10.7
#RUN mv apache-ant-${ANT_VERSION} /opt/ant
#ENV ANT_HOME /opt/ant
#ENV PATH ${PATH}:/opt/ant/bin
RUN rm -rf /opt/java-11.0.14 /opt/sonar-scanner-4.8.0.2856 && yum clean all && rm -rf /var/cache/yum

# Set JDK to be 32bit
COPY set_java $M2
RUN chmod +x $M2/set_java && $M2/set_java && rm $M2/set_java

CMD ["mvn","-version"]