ARG TAG
ARG REGISTRY_REPO
FROM --platform=$BUILDPLATFORM $REGISTRY_REPO/amamba/jenkins:$TAG-amd64 as build

FROM release-ci.daocloud.io/amamba/jenkins-base:2.346.2
COPY --from=build /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENTRYPOINT ["tini", "--", "/usr/local/bin/jenkins.sh"]
