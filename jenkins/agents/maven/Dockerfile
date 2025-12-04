# Usa la imagen base con JDK 17, construida sobre Alpine.
# Esta es más precisa y garantiza que iniciamos con el JDK deseado (JDK 17).
FROM jenkins/inbound-agent:alpine3.22-jdk17

# Cambia a root para instalar herramientas (Maven, Git, Node.js)
USER root

# --- Instalación de Herramientas Base ---
# Instala Bash, cURL, Unzip, Git, y Node.js/npm usando apk
RUN apk add --no-cache bash curl unzip git nodejs npm

# --- Instalación de Maven ---
# 1. Define la versión de Maven y el directorio de instalación
ARG MAVEN_VERSION=3.9.6
ARG MAVEN_HOME=/usr/share/maven
# 2. Descarga, verifica e instala Maven
RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    | tar -xzf - -C /usr/share/ \
    && mv /usr/share/apache-maven-$MAVEN_VERSION $MAVEN_HOME \
    && ln -s $MAVEN_HOME/bin/mvn /usr/bin/mvn

# 3. Limpia la caché de apk para reducir el tamaño final de la imagen
RUN rm -rf /var/cache/apk/*

# --- Configuración Final ---
# Vuelve al usuario jenkins (práctica recomendada de seguridad)
USER jenkins

# Define la variable de entorno M2_HOME para que Jenkins y scripts la reconozcan
ENV M2_HOME=$MAVEN_HOME
# -----------------------------