FROM jenkins/inbound-agent:alpine-jdk17

USER root

# Instalar Docker CLI
RUN apk add --no-cache docker-cli

RUN apk add --no-cache bash curl unzip git python3 py3-pip

RUN pip install --break-system-packages --no-cache-dir awscli

# Descargar imagen de Checkov (para usarla luego con 'docker run ...')
RUN pip install --break-system-packages --no-cache-dir checkov

USER jenkins
