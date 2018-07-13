#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y python-pip python-setuptools python-magic sqlite3 python3-pip libfuzzy-dev yara libyara-dev sshpass
sudo pip install yapsy
sudo pip install distorm3
sudo pip install yara-python
sudo pip install simplejson
sudo pip install pydeep
sudo pip install bottle
sudo pip install pefile

git clone https://github.com/KoreLogicSecurity/mastiff.git
find mastiff/mastiff.conf -type f -exec sed -i 's#yara_sigs = /usr/local/yara#yara_sigs = /usr/local/bin/#' {} \;

cat << EOT >> api.py
#!flask/bin/python
import os
import json
import copy
import argparse
import tempfile
import time
import glob

from bottle import route, request, response, run
from bottle import HTTPError
import urllib
import urllib2
import shutil

def jsonize(data):
    return json.dumps(data, sort_keys=False, indent=4)

@route('/add', method='POST')
def do_upload():

    upload = request.files.get('file')
  #  name, ext = os.path.splitext(upload.file) #Use for disabling file with extensions

  #  if ext in ('.'):
  #      return "File extension not allowed." 

    save_path = "/home/mastiff/mastiff/work"

    file_path = "{path}/{file}".format(path=save_path, file=upload.filename)
    upload.save(file_path)

    list_of_files = glob.glob('/home/mastiff/mastiff/work/*') # * means all if need specific format then *.csv
    latest_file = max(list_of_files, key=os.path.getctime)
  #  latest_file = latest_file[24:] #If you need only name of file, not a path
    os.system('sudo python /home/mastiff/mastiff/mas.py ' + latest_file)

    os.system('sudo rm ' + latest_file)
    os.system('sudo rm /home/mastiff/mastiff/work/log/mastiff.log')
    os.system('sudo rm /home/mastiff/mastiff/work/log/mastiff.db')


    list_of_analysis = glob.glob('/home/mastiff/mastiff/work/log/*') # * means all if need specific format then *.csv
    latest_analysis = max(list_of_analysis, key=os.path.getctime)
    latest_analysis1 = latest_analysis[28:]
    print(latest_analysis1)
    print(latest_analysis)


    os.system("cd /home/mastiff/mastiff/work/log/ && zip -r " + latest_analysis1 + " " + latest_analysis1)

    os.system("sshpass -p fame scp -o StrictHostKeyChecking=no /home/mastiff/mastiff/work/log/" + latest_analysis1 + ".zip fame@192.168.54.85:/home/fame/fame/fame/modules/community/processing/mastiff/storage/ && sudo rm /home/mastiff/mastiff/work/log/" + latest_analysis1 + ".zip")

    return jsonize({'message':'File successfully analysed'})


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-H', '--host', help='Host to bind the API server on', default='0.0.0.0', action='store', required=False)
    parser.add_argument('-p', '--port', help='Port to bind the API server on', default=8080, action='store', required=False)
    args = parser.parse_args()
    run(host=args.host, port=args.port)

EOT

mv api.py /home/mastiff/mastiff/

cd /home/mastiff/mastiff && sudo make install 

source /tmp/Network.conf
cat /etc/network/interfaces | sudo sed -i s/dhcp/static/ > sudo /etc/network/interfaces; echo -e "     address $mas_address\n     netmask $mas_netmask\n     network $mas_network\n     broadcast $mas_broadcast\n     gateway $mas_gateway\n     dns-nameservers $mas_dns" | sudo tee -a /etc/network/interfaces
