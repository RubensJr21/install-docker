#!/bin/bash
apt update;
apt install -y apt-transport-https ca-certificates curl software-properties-common;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -;
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable";
apt update;
apt install -y docker-ce docker-compose-plugin docker-compose;
echo -e "[boot]\ncommand = service docker start" >> /etc/wsl.conf;
# Será passado o nome do usuário pelo comando que irá chamar o script
usermod -aG docker $1;
