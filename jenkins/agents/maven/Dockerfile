# Use an official Maven image that already includes JDK 17
FROM maven:3.9-eclipse-temurin-17

# Switch to root to install necessary tools
USER root

# Install Jenkins agent dependencies
RUN apt-get update && apt-get install -y openssh-client

# Create a Jenkins user and working directory
RUN useradd -ms /bin/bash jenkins
USER jenkins
WORKDIR /home/jenkins