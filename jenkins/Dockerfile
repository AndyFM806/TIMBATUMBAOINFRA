FROM jenkins/jenkins:latest-jdk17

# Switch to the root user to install dependencies
USER root

# Disable the setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Copy the plugins file and install them
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Set the location of the JCasC configuration file
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins.yaml

# Expose the necessary ports
EXPOSE 8080 50000

# Healthcheck to ensure Jenkins is ready before proceeding
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD curl -f http://localhost:8080/login || exit 1