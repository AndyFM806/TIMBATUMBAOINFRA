# ----------------------------------------------------
# CAMBIO CLAVE: Usamos la etiqueta que especifica JDK 17
FROM jenkins/inbound-agent:alpine3.22-jdk17
# ----------------------------------------------------

# Cambia a root para instalar herramientas
USER root

# Instala Bash, cURL, Unzip, Git, Node.js y npm
RUN apk add --no-cache bash curl unzip git nodejs npm

# Vuelve al usuario jenkins (práctica recomendada de seguridad)
USER jenkins