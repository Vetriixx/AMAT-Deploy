#Thug honeyclient auto install
#CustomUploader to get the valid API from FAME and post each saved binary for a diagnostics
#Tested on Ubuntu Server 16.04.3

#!/bin/bash

sudo mkdir -p /home/thug /opt/thug/logs

# Install Dependicies
sudo apt-get install -y build-essential python-dev python-setuptools libboost-python-dev libboost-all-dev python-pip libxml2-dev libxslt-dev git libtool graphviz-dev automake libffi-dev graphviz libfuzzy-dev libjpeg-dev pkg-config autoconf

sudo rm -rf /var/lib/apt/lists/*

sudo python2.7 -m pip install -U setuptools
sudo easy_install -U pygraphviz==1.3.1
sudo python2.7 -m pip install pymongo
sudo python2.7 -m pip install pygraphviz

cd /home

sudo git clone https://github.com/buffer/pyv8.git
cd pyv8
sudo python2.7 setup.py build
sudo python2.7 setup.py install
cd ..
sudo rm -rf pyv8

sudo python2.7 -m pip install thug --ignore-installed six

sudo echo "/opt/libemu/lib/" > /etc/ld.so.conf.d/libemu.conf && ldconfig

sudo apt-get update
sudo apt-get -y upgrade

#Get Thugfeed and CustomUploader
sudo mv /home/dionaea/CustomUploader.py /usr/local/lib/python2.7/dist-packages/thug/Logging/CustomUploader.py
sudo mv /home/dionaea/dionaea/compare.py /opt/thug/
sudo mv /home/dionaea/dionaea/feedthug.sh /opt/thug/
sudo mv /home/dionaea/dionaea/thug.conf /etc/init/
#sudo mv ~/feedthugLocal.sh /opt/thug/    #optional

sudo chmod 775 /opt/thug/feedthug.sh
#sudo chmod 775 /opt/thug/feedthugLocal.sh

#Modify ThugLogging.py to auto start CustomUploader when the file is saved from currently diagnosed website
sudo sed -i '24i\from CustomUploader import CustomUploader\n' /usr/local/lib/python2.7/dist-packages/thug/Logging/ThugLogging.py
sudo sed -i '324i\        try:\n            CustomUploader(fname)\n            logger.debug("Upload complete via Uploader")\n        except BaseException as e:\n            logger.debug("There was a problem uploading via CustomerUploader: " + str(e))\n' /usr/local/lib/python2.7/dist-packages/thug/Logging/ThugLogging.py

source /tmp/Network.conf
sudo sed -i -e "s;fame_ip;$fame_address;;;" /usr/local/lib/python2.7/dist-packages/thug/Logging/CustomUploader.py

cd /opt/thug/
sleep 1800    # Wait until all other systems are up and start URLs diagnostics
sudo ./feedthug.sh
