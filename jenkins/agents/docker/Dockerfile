# Usar una imagen oficial de Docker
FROM docker:cli

# Instalar Java y curl (para el agente de Jenkins)
RUN apk add --no-cache \
    openjdk17-jre \
    curl

# Instalar el agente de Jenkins
RUN mkdir -p /usr/share/jenkins
RUN curl -sL "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/latest/remoting.jar" -o /usr/share/jenkins/agent.jar \
    && chmod 755 /usr/share/jenkins/agent.jar

# Crear usuario y directorio de trabajo
RUN adduser -D -s /bin/sh jenkins
USER jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/agent.jar"]
