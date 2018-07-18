#Vetriixx + Mowgli + ravac66
#Following the procedure in post requests for FAME and intergrated to DIONAEA/Thug to auto send any malware it receives.
#Honeypot --> Api Key from FAME --> Honeypot
#API key auto update

from sshtunnel import SSHTunnelForwarder, create_logger
from pymongo import MongoClient
import requests
import os
import json


MONGO_HOST = 'fame_ip' #FAME
MONGO_DB = "fame"
q = {}
api_key = None

def ObjectId(x):
	x=None
	return x

def get_api_fame():
	api_file =open("/tmp/.donotopen", "w+")
	with SSHTunnelForwarder(
		MONGO_HOST,
		ssh_username="fame",   # auto script to have fame + fame
		ssh_password="fame",
		remote_bind_address=('127.0.0.1', 3306),
		logger=create_logger(loglevel=1)
	) as server:

		server.start()
		client = MongoClient('fame_ip', 27017) # server.local_bind_port is assigned local port
		db = client[MONGO_DB]
		col = db.users.find()

		for doc in col:
			q.update(doc)
		api_file.write(q[u'api_key'])
	server.stop()
	api_file.close()

def api_check():

	try:
		api_key =open("/tmp/.donotopen", "r").read()
	except:
		get_api_fame()
		api_key =open("/tmp/.donotopen", "r").read()
	return api_key

def post_file(api, n):
	headers = {
		'Accept': "application/json",
		'X-API-KEY': api
		}
	endpoint = 'http://fame_ip/analyses/'	#FAME IP/PORT
	with open(n, 'rb') as f:
		params = {
                'options[allow_internet_access]':  "on",
                'options[analysis_time]': "100",
                'groups': "cert"
		}
		files = {'file': f}
		r = requests.post(endpoint, data=params, files=files, headers=headers)
		return r.text

def CustomUploader(n):
	try:
		a = post_file(api_check(), n)
		a = a.replace('"', '\"')
		d = json.loads(a)

	except:
		get_api_fame()
		a = post_file(api_check(), n)
		a = a.replace('"', '\"')
		d = json.loads(a)
