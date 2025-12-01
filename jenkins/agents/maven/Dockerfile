
FROM jenkins/inbound-agent:jdk17
USER root
ARG MAVEN_VERSION=3.9.6
ARG USER_HOME_DIR="/root"
RUN apt-get update && apt-get install -y wget
RUN wget http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xvf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /usr/share/maven && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
USER jenkins
