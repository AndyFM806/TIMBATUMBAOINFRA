# Usar la imagen oficial de Node.js
FROM node:18-slim

# Instalar curl y Java (necesarios para el agente de Jenkins)
RUN apt-get update && apt-get install -y \
    curl \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Instalar el agente de Jenkins
RUN mkdir -p /usr/share/jenkins
RUN curl -sL "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/latest/remoting.jar" -o /usr/share/jenkins/agent.jar \
    && chmod 755 /usr/share/jenkins/agent.jar

# Crear usuario y directorio de trabajo
RUN useradd -ms /bin/bash jenkins
USER jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/agent.jar"]
