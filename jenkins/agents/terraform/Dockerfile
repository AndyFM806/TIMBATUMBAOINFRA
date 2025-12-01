
FROM jenkins/inbound-agent:jdk17
USER root
RUN apt-get update && apt-get install -y wget unzip && \
    wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip && \
    unzip terraform_1.7.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.7.0_linux_amd64.zip
RUN wget https://github.com/im2nguyen/rover/releases/download/v0.0.1-alpha/rover_0.0.1-alpha_linux_amd64.tar.gz && \
    tar -xzf rover_0.0.1-alpha_linux_amd64.tar.gz && \
    mv rover /usr/local/bin/
USER jenkins
