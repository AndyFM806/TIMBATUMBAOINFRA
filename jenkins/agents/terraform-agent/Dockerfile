FROM alpine:3.19

RUN apk add --no-cache \
  curl \
  unzip \
  bash \
  git \
  python3 \
  py3-pip

# Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip -o terraform.zip \
  && unzip terraform.zip \
  && mv terraform /usr/local/bin/terraform

CMD ["bash"]
