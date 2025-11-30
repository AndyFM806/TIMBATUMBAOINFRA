FROM jenkins/jenkins:jdk21

USER root

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Solo plugins, el YAML se montará desde la máquina host
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/plugins.txt

# JCasC leerá este archivo (montado por docker-compose)
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc/jenkins.yaml

USER jenkins

EXPOSE 8080 50000
