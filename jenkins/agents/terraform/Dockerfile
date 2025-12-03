# Usamos una base de Ubuntu para compatibilidad de paquetes
FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias básicas, Java, Docker CLI y otras herramientas
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    jq \
    software-properties-common \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI (para Checkov)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli

# Instalar Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get update && apt-get install -y terraform

# Instalar AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Instalar el agente de Jenkins (inbound-agent)
RUN mkdir -p /usr/share/jenkins
RUN curl -sL "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/latest/remoting.jar" -o /usr/share/jenkins/agent.jar \
    && chmod 755 /usr/share/jenkins/agent.jar

# Crear usuario 'jenkins' para correr el agente
RUN useradd -ms /bin/bash jenkins
USER jenkins
WORKDIR /home/jenkins

# Punto de entrada para que Jenkins se conecte
ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/agent.jar"]
