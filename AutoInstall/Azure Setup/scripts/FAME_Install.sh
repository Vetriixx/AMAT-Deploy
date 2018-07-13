#!/bin/bash

#Update Packages
sudo apt-get update 
sudo apt-get -y upgrade

sudo apt install -y -qq aptitude
sudo aptitude -y install expect

#Install Dependicies
sudo apt-get install -y ssh git python-pip python-dev nginx
sudo pip install virtualenv

sudo apt-get install -y ssh git python-pip python-dev nginx libmysqlclient-dev
sudo pip install virtualenv sshtunnel mysql-connector==2.1.4 mysqlclient

#Set fame password

passwd_fame=$(expect -c "
sudo passwd fame
expect \"Enter new UNIX password:\"
send \"fame\r\" 
expect \"Retype new UNIX password:\"
send \"fame\r\"
expect eof
")

echo "$passwd_fame$" 

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

install=$(expect -c "
set timeout 9999999999999999999999999999999999999999999999999999999999999
spawn sudo utils/run.sh utils/install.py
expect \"MongoDB host\"
send \"0.0.0.0\r\"
expect \"MongoDB port\"
send \"\r\"
expect \"MongoDB database\"
send \"\r\"
expect \"Installation type\"
send \"1\r\"
expect \"FAME's URL for users (e.g. https://fame.yourdomain/):\"
send \"$IP\r\"
expect \"Full Name:\"
send  \"fame\r\"
expect \"Email Address:\"
send \"fame@fame.fame\r\"
expect \"Groups (comma-separated)\"
send \"\r\"
expect \"Password:\"
send \"fame\r\"
expect \"Confirm:\"
send \"fame\r\"
expect eof
")

echo "$install$"

sudo chown -R fame:fame /home/fame/fame 

sudo sed -i 's:bindIp\: 127.0.0.1:bindIp\: 0.0.0.0:g' /etc/mongod.conf
sudo service mongod restart

sudo rm -r /home/fame/fame/fame/modules/community/processing/cuckoo_modified

#Set up folders and get files for modules
cd /home/fame/fame/fame/modules/community/processing/
sudo mkdir mastiff mastiff/storage viper cuckoo_modified

sudo mv /home/fame/Mastiff.py mastiff/
sudo touch mastiff/__init__.py

sudo mv /home/fame/viper.py viper/
sudo touch viper/__init__.py

sudo mv /home/fame/cuckoo_modified/* cuckoo_modified/
sudo touch cuckoo_modified/__init__.py

sudo rm ~/README.md

sudo chmod 757 /home/fame/fame/fame/modules/community/processing/mastiff/storage/

sudo su
#Create Daemon
sudo pip install uwsgi

#Create services to auto start FAME
printf "[Unit]\nDescription=FAME web server\n\n[Service]\nType=simple\nExecStart=/bin/bash -c \'cd /home/fame/fame  && uwsgi -H /home/fame/fame/env --uid 1000 --gid 1000 --socket /tmp/fame.sock --chmod-socket=660 --chown-socket fame:www-data -w webserver --callable app\'\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/fame_web.service

printf "[Unit]\nDescription=FAME workers\n\n[Service]\nType=simple\nUser=fame\nExecStart=/bin/bash -c \'cd /home/fame/fame && utils/run.sh worker.py\'\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/fame_worker.service

sudo systemctl enable fame_web
sudo systemctl enable fame_worker
sudo systemctl start fame_web
sudo systemctl start fame_worker
sudo rm /etc/nginx/sites-enabled/default

#Edit webserver configuration 
printf "upstream fame {\n\tserver unix:///tmp/fame.sock;\n}\n\nserver {\n\tlisten 80 default_server;\n\n\t# Allows big file upload\n\tclient_max_body_size 0;\n\n\tlocation / {\n\t\tinclude uwsgi_params;\n\t\t	uwsgi_pass fame;\n\t}\n\n\tlocation /static/ {\n\t\talias /home/fame/fame/web/static/;\n\t}\n}" | tee /etc/nginx/sites-available/fame

sudo ln -s /etc/nginx/sites-available/fame /etc/nginx/sites-enabled/fame
sudo systemctl restart nginx

api="$(printf "use fame\ndb.users.distinct(\"api_key\")\n" | mongo | grep -o '".*"' | sed 's/\"//g')"

curl -XPOST -H "X-API-KEY: $api" http://127.0.0.1/modules/reload

printf "use fame\ndb.modules.updateMany({\"name\": \"cuckoo_modifi\"}, {\$set: {\"enabled\":true}}, {upsert: true})\ndb.modules.updateMany({\"name\": \"viper\"}, {\$set: {\"enabled\":true}}, {upsert: true})\ndb.modules.updateMany({\"name\": \"mastiff\"}, {\$set: {\"enabled\":true}}, {upsert: true})" | mongo

sudo mv ~/get_api.py /home/fame/

sudo chmod +x /home/fame/get_api.py

printf "[Unit]\nDescription=Get MISP API\n\n[Service]\nWorkingDirectory=/home/fame/\nExecStart=/home/fame/get_api.py\nUser=fame\nGroup=fame\nStandardOutput=tty\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/get_misp_api.service

sudo systemctl enable get_misp_api
sudo systemctl start get_misp_api

#Import the IP address from each machine into te FAME module configuraton so each VM can communicate

source /tmp/Network.conf
#cuckoo.py
sudo sed -i -e "s;cuckoo_ip;$cuck_address;;;" /home/fame/fame/fame/modules/community/processing/cuckoo_modifed/cuckoo.py

#Mastiff.py
sudo sed -i -e "s;mastiff_ip;$mas_address;;;" /home/fame/fame/fame/modules/community/processing/mastiff/Mastiff.py

#viper.py
sudo sed -i -e "s;viper_ip;$vip_address;;;" /home/fame/fame/fame/modules/community/processing/viper/viper.py

#get_api.py
sudo sed -i -e "s;misp_ip;$misp_address;;;" /home/fame/fame/get_api.py

#MISPmod.py
sudo sed -i -e "s;cuckoo_ip;$cuck_address;;;" /home/fame/fame/fame/modules/community/processing/cuckoo_modifed/MISPmod.py
sudo sed -i -e "s;misp_ip;$misp_address;;;" /home/fame/fame/fame/modules/community/processing/cuckoo_modifed/MISPmod.py

exit 0
