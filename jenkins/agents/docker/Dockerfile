# Usa la imagen base con JDK 21 (o cámbiala a jdk17 si lo prefieres)
FROM jenkins/inbound-agent:alpine3.22-jdk21

# Cambia a root para instalar herramientas
USER root

# --- Instalación de Herramientas Base ---
# Instala Bash, cURL, Unzip, Git, Python 3 y pip
# 3. Instalación de Herramientas Base (curl, unzip, git, tar, python, etc.)
# Usamos '--no-cache' para reducir el tamaño final de la imagen.
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    git \
    python3 \
    py3-pip \
    tar

# --- Instalación de AWS CLI ---
# Instala AWS CLI usando pip
RUN pip install --break-system-packages --no-cache-dir awscli

# --- Instalación de Terraform 1.14.0 ---
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.14.0/terraform_1.14.0_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# --- Instalación de Checkov ---
RUN pip install --break-system-packages --no-cache-dir checkov

# -----------------------------------------------
# PASO CLAVE: INSTALACIÓN DEL CLIENTE DOCKER
# -----------------------------------------------
# Instala el cliente CLI de Docker. Esto NO instala el demonio (daemon) de Docker.
RUN apk add --no-cache docker

# Vuelve al usuario jenkins (práctica recomendada de seguridad)
USER jenkins