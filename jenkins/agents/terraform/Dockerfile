# Usa la imagen base con JDK 21
FROM jenkins/inbound-agent:alpine3.22-jdk21

# Cambia a root para instalar herramientas del sistema y paquetes
USER root

# --- Instalación de Herramientas Base ---
# Instala Bash, cURL, Unzip, Git, Python 3 y pip
RUN apk add --no-cache bash curl unzip git python3 py3-pip

# --- Instalación de AWS CLI ---
# Instala AWS CLI usando pip
RUN pip install --break-system-packages --no-cache-dir awscli

# --- Instalación de Terraform 1.14.0 ---
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.14.0/terraform_1.14.0_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# VERIFICACIÓN: Opcional, pero recomendado, para confirmar la instalación de Terraform
# RUN terraform --version

# --- Instalación de Checkov ---
# Instala Checkov (herramienta de seguridad para IaC)
RUN pip install --break-system-packages --no-cache-dir checkov

# Vuelve al usuario jenkins (práctica recomendada de seguridad)
USER jenkins