#!/bin/bash

sudo apt install -y -qq aptitude
sudo aptitude -y install expect
PYTHON_PIP=$(expect -c "
set timeout 30
spawn sudo apt-get install -y python-pip
expect\"*** 10periodic (Y/I/N/O/D/Z) [default=N] ?\"
send \"Y\r\"
expect eof
")
echo "$PYTHON_PIP"

sudo apt-get install -y apmd uml-utilities bridge-utils linux-headers-$(uname -r) systemtap gcc
sudo -H pip install watchdog observer python-debug ptrace
sudo apt-get install -y uml-utilities

cat /etc/network/interfaces | sudo sed -i s/dhcp/static/ > sudo /etc/network/interfaces; echo -e "     address ip_address\n     netmask 255.255.255.0\n     network 192.168.56.0\n     broadcast 192.168.56.255\n     gateway 192.168.56.1\n     dns-nameservers 192.168.56.1" | sudo tee -a /etc/network/interfaces

exit
