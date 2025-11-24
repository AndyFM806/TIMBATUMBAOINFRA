FROM jenkins/jenkins:lts-jdk21

USER root

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Copiar plugins y JCasC
COPY plugins.txt /usr/share/jenkins/plugins.txt
COPY jcasc/jenkins.yaml /usr/share/jenkins/jenkins.yaml

# INSTALAR plugins correctamente
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/plugins.txt

USER jenkins
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/jenkins.yaml

EXPOSE 8080 50000
