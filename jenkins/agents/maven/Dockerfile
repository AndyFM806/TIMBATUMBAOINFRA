# Usar una imagen oficial de Maven que ya incluye JDK 17
FROM maven:3.9-eclipse-temurin-17

# Instalar el agente de Jenkins (y las carpetas necesarias)
RUN mkdir -p /usr/share/jenkins
RUN curl -sL "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/latest/remoting.jar" -o /usr/share/jenkins/agent.jar \
    && chmod 755 /usr/share/jenkins/agent.jar

# Crear usuario y directorio de trabajo
RUN useradd -ms /bin/bash jenkins
USER jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/agent.jar"]
