FROM ubuntu:22.04
RUN  apt update && \
     export DEBIAN_FRONTEND=noninteractive && \
     apt install ansible -y && \
     apt install unzip -y && \
     apt install curl -y && \
     curl -sLO https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip && \
     unzip terraform_1.3.7_linux_amd64.zip && \
     rm terraform_1.3.7_linux_amd64.zip && \
     mv terraform /usr/local/bin && \
     apt clean && \
     apt autoclean  && \
     mkdir /lab
WORKDIR /lab