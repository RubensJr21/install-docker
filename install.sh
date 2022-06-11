#!/bin/bash
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update
apt install -y docker-ce docker-compose-plugin docker-compose

#Execute systeminfo.exe and pass for egrep command and it get who windows is running in host machine, afeter get only numbers using regex
WINDOWS_VERSION=$(systeminfo.exe | grep -Po "Windows ([0-9]{2})" | grep -Po "([0-9]{2})")

if [ "$WINDOWS_VERSION" = "11" ]; then
    #Work only in Windows 11
    exists=$(ls -la /etc | grep wsl.conf)
    if [ -z "$exists" ]; then
        sudo echo -e "[boot]\ncommand = service docker start" > /etc/wsl.conf
    else
        result=$(cat /etc/wsl.conf | grep -Po "command = service docker start")
        if [ -z "$result" ]; then
            sudo echo -e "[boot]\ncommand = service docker start" >>/etc/wsl.conf
        fi
    fi
elif [ "$WINDOWS_VERSION" = "10" ]; then
    #alternative for Windows 10
    #Return "" (empty) if not founded line in file
    result=$(cat /etc/sudoers | grep -Po "$USER ALL=(ALL) NOPASSWD: /usr/sbin/service")

    #Verify if the command isn't in file
    if [ -z "$result" ]; then
        cp /etc/sudoers /tmp/sudoers.bak
        #Command for executing service without password
        echo -e "\n$USER ALL=(ALL) NOPASSWD: /usr/sbin/service" >>/tmp/sudoers.bak
        visudo -cf /tmp/sudoers.bak
        if [ $? -eq 0 ]; then
            # Replace the sudoers file with the new only if syntax is correct.
            sudo cp /tmp/sudoers.bak /etc/sudoers
            result=$(cat ~/.bashrc | grep -Po "Genereted by Install-docker-on-wsl")
            # Case the line isn't in file put the commands
            if [ -z "$result" ]; then
                echo "" >>~/.bashrc
                echo "Genereted by Install-docker-on-wsl (https://github.com/RubensJr21/install-docker-in-wsl)" >>~/.bashrc
                echo '# Start Docker daemon automatically when logging in if not running.' >>~/.bashrc
                echo 'RUNNING=`ps aux | grep docker | grep -v grep`' >>~/.bashrc
                echo 'if [ -z "$RUNNING" ]; then' >>~/.bashrc
                echo '    sudo service docker start > /dev/null 2>&1 &' >>~/.bashrc
                echo '    disown' >>~/.bashrc
                echo 'fi' >>~/.bashrc
                echo "========================================================================================" >>~/.bashrc
                echo "" >>~/.bashrc
            fi
        fi
    fi
fi
usermod -aG docker $USER
