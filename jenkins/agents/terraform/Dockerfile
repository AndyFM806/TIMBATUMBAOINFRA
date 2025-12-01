# Usamos una imagen base de Debian que es ligera
FROM debian:trixie-slim

# Nos aseguramos de correr los comandos como root para instalar paquetes
USER root

# Instala las herramientas necesarias y Terraform
RUN apt-get update && apt-get install -y wget unzip && \
    wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip && \
    unzip terraform_1.7.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/

# Cambiamos de nuevo al usuario jenkins para seguir las buenas prácticas
USER jenkins
