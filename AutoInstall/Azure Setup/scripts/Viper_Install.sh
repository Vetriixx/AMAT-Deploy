#!/bin/bash
#Viper Installation on Ubuntu Server 16

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y python2.7 gcc python-dev python-pip libssl-dev swig
sudo python2.7 -m pip install SQLAlchemy PrettyTable python-magic

cd ~
wget http://sourceforge.net/projects/ssdeep/files/ssdeep-2.13/ssdeep-2.13.tar.gz/download
mv download ssdeep
tar -zxvf ssdeep
cd ssdeep-2.13
./configure && make
sudo make install

sudo pip install pydeep

cd ~
wget https://github.com/viper-framework/viper/archive/v1.2.tar.gz
tar -zxvf v1.2.tar.gz
cd viper-1.2
sudo python2.7 -m pip install -r requirements.txt
echo -e "[Unit]\nDescription=Viper APIService\n\n[Service]\nWorkingDirectory=/home/viper/viper-1.2/\nExecStart=/home/viper/viper-1.2/api.py -H 0.0.0.0 -p 8090\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/viper_api.service
echo -e "[Unit]\nDescription=Viper WebService\n\n[Service]\nWorkingDirectory=/home/viper/viper-1.2/\nExecStart=/home/viper/viper-1.2/web.py -H 0.0.0.0 -p 8080\n\n[Install]\nWantedBy=multi-user.target" |  sudo tee /etc/systemd/system/viper_web.service
echo -e "[Unit]\nDescription=Viper Service\n\n[Service]\nWorkingDirectory=/home/viper/viper-1.2/\nExecStart=/home/viper/viper-1.2/viper.py\n\n[Install]\nWantedBy=multi-user.target" |  sudo tee /etc/systemd/system/viper.service

sudo systemctl enable viper_api
sudo systemctl enable viper_web
sudo systemctl enable viper
sudo systemctl start viper
sudo systemctl start viper_web
sudo systemctl start viper_api
