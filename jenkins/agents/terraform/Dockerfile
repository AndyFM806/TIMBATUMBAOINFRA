FROM debian:trixie-slim
USER root
RUN apt-get update && apt-get install -y wget unzip && \
    useradd -ms /bin/bash jenkins && \
    wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip && \
    unzip terraform_1.7.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/
USER jenkins
LABEL com.docker.compose.image.builder=classic
