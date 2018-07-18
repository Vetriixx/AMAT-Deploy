#!/bin/bash

#Update Packages
sudo apt-get update 
sudo apt-get -y upgrade

#Install Dependicies
sudo apt-get install -y ssh git python-pip python-dev nginx
sudo pip install virtualenv

sudo apt-get install -y ssh git python-pip python-dev nginx libmysqlclient-dev
sudo pip install virtualenv sshtunnel mysql-connector==2.1.4 mysqlclient

#Mongo Install
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo systemctl enable mongod
sudo systemctl start mongod

#Download FAME
git clone https://github.com/certsocietegenerale/fame
sudo chown -R fame:fame fame 
cd fame

#Install FAME
IP=$(hostname -I | cut -f1 -d' ')
echo -e "fame" | su fame
echo -e "0.0.0.0\n\n\n1\n$IP\nfame\nfame@fame.fame\n\nfame\nfame\n" | utils/run.sh utils/install.py
sudo chown -R fame:fame /home/fame/fame 

sudo sed -i 's:bindIp\: 127.0.0.1:bindIp\: 0.0.0.0:g' /etc/mongod.conf
sudo service mongod restart

sudo rm -r /home/fame/fame/fame/modules/community/processing/cuckoo_modified

#Set up folders and get files for modules
cd /home/fame/fame/fame/modules/community/processing/
sudo mkdir mastiff mastiff/storage viper cuckoo_modified

sudo mv ~/Mastiff.py mastiff/
sudo touch mastiff/__init__.py

sudo mv ~/viper.py viper/
sudo touch viper/__init__.py

sudo mv ~/cuckoo_modified/* cuckoo_modified/
sudo touch cuckoo_modified/__init__.py

sudo rm ~/README.md

sudo chmod 757 /home/fame/fame/fame/modules/community/processing/mastiff/storage/

sudo su
#Create Daemon
sudo pip install uwsgi

printf "[Unit]\nDescription=FAME web server\n\n[Service]\nType=simple\nExecStart=/bin/bash -c \'cd /home/fame/fame  && uwsgi -H /home/fame/fame/env --uid 1000 --gid 1000 --socket /tmp/fame.sock --chmod-socket=660 --chown-socket fame:www-data -w webserver --callable app\'\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/fame_web.service

printf "[Unit]\nDescription=FAME workers\n\n[Service]\nType=simple\nUser=fame\nExecStart=/bin/bash -c \'cd /home/fame/fame && utils/run.sh worker.py\'\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/fame_worker.service

sudo systemctl enable fame_web
sudo systemctl enable fame_worker
sudo systemctl start fame_web
sudo systemctl start fame_worker
sudo rm /etc/nginx/sites-enabled/default

printf "upstream fame {\n\tserver unix:///tmp/fame.sock;\n}\n\nserver {\n\tlisten 80 default_server;\n\n\t# Allows big file upload\n\tclient_max_body_size 0;\n\n\tlocation / {\n\t\tinclude uwsgi_params;\n\t\t	uwsgi_pass fame;\n\t}\n\n\tlocation /static/ {\n\t\talias /home/fame/fame/web/static/;\n\t}\n}" | tee /etc/nginx/sites-available/fame

sudo ln -s /etc/nginx/sites-available/fame /etc/nginx/sites-enabled/fame
sudo systemctl restart nginx

api="$(echo -e "use fame\ndb.users.distinct(\"api_key\")\n" | mongo | grep -o '".*"' | sed 's/\"//g')"

curl -XPOST -H "X-API-KEY: $api" 'http://127.0.0.1/modules/reload'

echo -e "use fame\ndb.modules.updateMany({\"name\": \"cuckoo_modifi\"}, {\$set: {\"enabled\":true}}, {upsert: true})\ndb.modules.updateMany({\"name\": \"viper\"}, {\$set: {\"enabled\":true}}, {upsert: true})\ndb.modules.updateMany({\"name\": \"mastiff\"}, {\$set: {\"enabled\":true}}, {upsert: true})" | mongo

sudo mv ~/get_api.py /home/fame/

sudo chmod +x /home/fame/get_api.py

echo -e "[Unit]\nDescription=Get MISP API\n\n[Service]\nWorkingDirectory=/home/fame/\nExecStart=/home/fame/get_api.py\nUser=fame\nGroup=fame\nStandardOutput=tty\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/get_misp_api.service

sudo systemctl enable get_misp_api
sudo systemctl start get_misp_api

source /tmp/Network.conf
#cuckoo.py
sudo sed -i -e "36s/cuck_ip/$cuck_address/" /home/fame/fame/fame/modules/community/processing/cuckoo_modified/cuckoo.py

#Mastiff.py
sudo sed -i -e "23s/mastiff_ip/$mas_address/" /home/fame/fame/fame/modules/community/processing/mastiff/Mastiff.py
sudo sed -i -e "29s/mastiff_ip/$mas_address/" /home/fame/fame/fame/modules/community/processing/mastiff/Mastiff.py

#viper.py
sudo sed -i -e "23s/viper_ip/$vip_address/" /home/fame/fame/fame/modules/community/processing/viper/viper.py
sudo sed -i -e "29s/viper_ip/$vip_address/" /home/fame/fame/fame/modules/community/processing/viper/viper.py

#get_api.py
sudo sed -i -e "10s/misp_ip/$misp_address/" /home/fame/get_api.py

#MISPmod.py
sudo sed -i -e "283s/cuckoo_ip/$cuck_address/" /home/fame/fame/fame/modules/community/processing/cuckoo_modified/MISPmod.py
sudo sed -i -e "290s/cuckoo_ip/$cuck_address/" /home/fame/fame/fame/modules/community/processing/cuckoo_modified/MISPmod.py
sudo sed -i -e "11s/misp_ip/$misp_address/" /home/fame/fame/fame/modules/community/processing/cuckoo_modified/MISPmod.py

cat /etc/network/interfaces | sudo sed -i s/dhcp/static/ > sudo /etc/network/interfaces; echo -e "     address $fame_address\n     netmask $fame_netmask\n     network $fame_network\n     broadcast $fame_broadcast\n     gateway $fame_gateway\n     dns-nameservers $fame_dns" | sudo tee -a /etc/network/interfaces
