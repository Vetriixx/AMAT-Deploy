#Dionaea honeypot auto install
#CustomUploader to get the valid API from FAME and post each saved binary for a diagnostics
#Tested on Ubuntu Server 14.04.5

#!/bin/bash

# Update Packages
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

# Move SSH server from Port 22 to Port 22222
# Uncomment if needed
#sudo apt-get install -y ssh
#sudo sed -i 's:Port 22:Port 22222:g' /etc/ssh/sshd_config
#sudo service ssh reload

# Install Dependicies
sudo apt-get install -y software-properties-common python3-pip mongodb
sudo pip3 install requests

sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install sshtunnel
sudo python3 -m pip install pymongo

sudo apt-get install -y python-pip
sudo python2.7 -m pip install --upgrade pip
sudo python2.7 -m pip install sshtunnel
sudo python2.7 -m pip install pymongo

# Add Dionaea repository
sudo add-apt-repository -y ppa:honeynet/nightly
sudo apt-get update

# Install Dionaea
sudo apt-get install -y dionaea

sudo chown -R nobody:nogroup /opt/dionaea/var/dionaea

# Change autostart
sudo sed -i 's:USER=dionaea:USER=nobody:g' /etc/init.d/dionaea
sudo sed -i 's:GROUP=dionaea:GROUP=nogroup:g' /etc/init.d/dionaea
sudo update-rc.d dionaea defaults

# Install p0f fingerprinting
sudo apt-get install -y p0f
sudo p0f -i any -u nobody -Q /tmp/p0f.sock -q -l -d -o /var/p0f/p0f.log
sudo chown nobody:nogroup /tmp/p0f.sock

# Enable p0f
sudo ln -s /opt/dionaea/etc/dionaea/ihandlers-available/p0f.yaml /opt/dionaea/etc/dionaea/ihandlers-enabled/p0f.yaml

sudo cp ~/CustomUploader.py /opt/dionaea/lib/dionaea/python/dionaea/CustomUploader.py
sudo rm ~/README.md

# Modify Store.py to auto start CustomUploader when the binary is saved
sudo sed -i '36i\import sys' /opt/dionaea/lib/dionaea/python/dionaea/store.py
sudo sed -i "37i\sys.path.append(\'/opt/dionaea/lib/dionaea/python/dionaea\')\n" /opt/dionaea/lib/dionaea/python/dionaea/store.py
sudo sed -i '38i\from CustomUploader import CustomUploader\n' /opt/dionaea/lib/dionaea/python/dionaea/store.py
sudo sed -i '95i\        try:\n            CustomUploader(n)\n            logger.debug("Upload complete via Uploader")\n        except BaseException as e:\n            logger.debug("There was a problem uploading via CustomerUploader: " + str(e))\n' /opt/dionaea/lib/dionaea/python/dionaea/store.py

source /tmp/Network.conf
sudo sed -i -e "s;fame_ip;$fame_address;;;" /opt/dionaea/lib/dionaea/python/dionaea/CustomUploader.py

sudo service dionaea start

source /tmp/Network.conf
cat /etc/network/interfaces | sudo sed -i s/dhcp/static/ > sudo /etc/network/interfaces; echo -e "     address $hp_address\n     netmask $hp_netmask\n     network $hp_network\n     broadcast $hp_broadcast\n     gateway $hp_gateway\n     dns-nameservers $hp_dns" | sudo tee -a /etc/network/interfaces
