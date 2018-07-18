import zipfile
import json
import requests
#import MySQLdb
#from sshtunnel import SSHTunnelForwarder
#from mysql.connector import (connection)


def get_api_key():
    #Gets MISP API key
    SQL_HOST='misp_ip'
    api_file = open("/tmp/.donotopen", "w")
    with SSHTunnelForwarder(
        SQL_HOST,
        ssh_username="misp",   # auto script to have fame + fame
        ssh_password="misp",
	local_bind_address=('127.0.0.1', 3306),
        remote_bind_address=('127.0.0.1', 3306)
    ) as server:
            server.start()
            cnx = connection = MySQLdb.connect(user='misp', passwd='misp', db='misp', host='127.0.0.1', port=3306)
            cursor = cnx.cursor()
            cursor.execute("SELECT authkey FROM users")
            # Get and display one row at a time
            api = cursor.fetchone()
            print(api[0])
            api_file.write(api[0])

            # Close the connection
            cnx.close()
    
    server.stop()
    api_file.close()

def api_check():
    try:
        api_key = open("/tmp/.donotopen", "r").read()
    except:
        get_api_key()
        api_key = open("/tmp/.donotopen", "r").read()
    return api_key


def create_misp_report(report):
    false=False
    null=None 
    true=True
    template = {
        "Event": {
            "date": "",
            "threat_level_id": "2",
            "event_creator_email": "admin@admin.test",
            "info": "testme",
            "analysis": "2",
            "published": false,
            "distribution": "1",
            "Attribute": [
                {
                    "category": "Other",
                    "comment": "Signatures",
                    "to_ids": false,
                    "value": "",
                    "distribution": "5",
                    "type": "text"
                }
            ],
            "Object": [
                {
                    "name": "sandbox-report",
                    "template_uuid": "4d3fffd2-cd07-4357-96e0-a51c988faaef",
                    "meta-category": "misc",
                    "description": "Sandbox report",
                    "distribution": "5",
                    "deleted": false,
                    "sharing_group_id": "0",
                    "comment": "",
                    "Attribute": [
                        {
                            "type": "text",
                            "category": "External analysis",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "object_relation": "score",
                            "value": ""
                        },
                        {
                            "type": "text",
                            "category": "Other",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "object_relation": "sandbox-type",
                            "value": "on-premise"
                        },
                        {
                            "type": "text",
                            "category": "Other",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "object_relation": "on-premise-sandbox",
                            "value": "cuckoo"
                        }
                    ]
                },
                {
                    "name": "virustotal-report",
                    "meta-category": "misc",
                    "description": "VirusTotal report",
                    "template_uuid": "d7dd0154-e04f-4c34-a2fb-79f3a3a52aa4",
                    "distribution": "5",
                    "sharing_group_id": "0",
                    "comment": "",
                    "deleted": false,
                    "Attribute": [
                        {
                            "id": "29",
                            "type": "link",
                            "category": "External analysis",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": false,
                            "object_relation": "permalink",
                            "value": ""

                        },
                        {
                            "type": "text",
                            "category": "External analysis",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": true,
                            "object_relation": "detection-ratio",
                            "value": ""
                        }
                    ]
                },
                {
                    "id": "8",
                    "name": "file",
                    "meta-category": "file",
                    "description": "File object describing a file with meta-information",
                    "template_uuid": "688c46fb-5edb-40a3-8273-1af7923e2215",
                    "template_version": "9",
                    "event_id": "2",
                    "uuid": "5a7d3dde-3260-4df0-b50e-6df1c0a83670",
                    "timestamp": "1518157278",
                    "distribution": "5",
                    "sharing_group_id": "0",
                    "comment": "",
                    "deleted": false,
                    "ObjectReference": [],
                    "Attribute": [
                        {
                            "type": "md5",
                            "category": "Payload delivery",
                            "to_ids": true,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": false,
                            "object_relation": "md5",
                            "value": ""
                        },
                        {
                            "type": "sha256",
                            "category": "Payload delivery",
                            "to_ids": true,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": false,
                            "object_relation": "sha256",
                            "value": ""
                        },
                        {
                            "type": "sha512",
                            "category": "Payload delivery",
                            "to_ids": true,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": false,
                            "object_relation": "sha512",
                            "value": ""
                        },
                        {
                            "type": "filename",
                            "category": "Payload delivery",
                            "to_ids": true,
                            "distribution": "5",
                            "comment": "",
                            "deleted": false,
                            "disable_correlation": true,
                            "object_relation": "filename",
                            "value": ""
                        },
                        {
                            "type": "text",
                            "category": "External analysis",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "Mastiff",
                            "deleted": false,
                            "disable_correlation": true,
                            "object_relation": "text",
                            "value": ""
                        },
                        {
                            "type": "size-in-bytes",
                            "category": "Other",
                            "to_ids": false,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": true,
                            "object_relation": "size-in-bytes",
                            "value": ""
                        },
                        {
                            "type": "ssdeep",
                            "category": "Payload delivery",
                            "to_ids": true,
                            "distribution": "5",
                            "comment": "",
                            "sharing_group_id": "0",
                            "deleted": false,
                            "disable_correlation": false,
                            "object_relation": "ssdeep",
                            "value": ""
                        }
                    ]
                }
            ]
        
        }
    }
    #Replace values with cuckoo_report values
    template['Event']['date'] = report['info']['ended'][0:10]
    template['Event']['threat_level_id'] = 2 #get_threat_level(report['malscore'],report['virustotal']['positives'],report['virustotal']['total'])
    template['Event']['info'] = report['target']['file']['name']
    template['Event']['Attribute'][0]['value'] = grab_signatures(report) #signatures from cuckoo

    #cuckoo object
    template['Event']['Object'][0]['Attribute'][0]['value'] = report['malscore'] # sandbox-report score  
    #template['Event']['Object'][0]['Attribute'][3]['value'] = report #raw-report

    #virustotal object
    template['Event']['Object'][1]['Attribute'][0]['value'] = report['virustotal']['permalink'] # virustotal-report link
    template['Event']['Object'][1]['Attribute'][1]['value'] = str(report['virustotal']['positives']) + '/' + str(report['virustotal']['total']) # virustotal-report score
    
    #file object
    template['Event']['Object'][2]['comment'] = report['target']['file']['type'] #File type 
    template['Event']['Object'][2]['Attribute'][0]['value'] = report['target']['file']['md5'] #md5 hash of file
    template['Event']['Object'][2]['Attribute'][1]['value'] = report['target']['file']['sha256'] #sha256 hash of file
    template['Event']['Object'][2]['Attribute'][2]['value'] = report['target']['file']['sha512'] #sha512 hash of file
    template['Event']['Object'][2]['Attribute'][3]['value'] = report['target']['file']['name'] #Name of file
    template['Event']['Object'][2]['Attribute'][4]['value'] = get_mastiff_report(report['target']['file']['md5']) #Mastiff mem dump
    template['Event']['Object'][2]['Attribute'][5]['value'] = str(report['target']['file']['size']) + 'bytes' #Size of file in bytes
    template['Event']['Object'][2]['Attribute'][6]['value'] = report['target']['file']['ssdeep'] #ssdeep hash of file
    return template


def get_cuckoo_json():
    id = get_cuckoo_idList()
    url = "http://cuckoo_ip:8090/tasks/report/" + str(id)
    r = requests.get(url)
    report = json.loads(r.text)
    return report


def get_cuckoo_idList():
    url = "http://cuckoo_ip:8090/tasks/list"
    r = requests.get(url)
    task = json.loads(r.text)
    id = task["tasks"][-1]['guest']['task_id']
    return id


def get_threat_level(malscore, positives, total):
    try:    
        malscore = float(malscore)
        positives = float(positives)
        total = float(total)
        avg = ((positives/total)+(malscore/10))/2
        threat = 0
        if avg >= 7:
            threat = 1
        elif avg > 4:
            threat = 2
        elif avg < 4:
            treat = 3 
    except:
        threat = 4
    return threat


def grab_signatures(report):
    formatted_sigs = ''
    for signature in report['signatures']:
        formatted_sigs = formatted_sigs + signature['description'] + '\r\n'


def get_mastiff_report(file_md5):
    with zipfile.ZipFile("/home/fame/fame/fame/modules/community/processing/mastiff/storage/" + file_md5 + ".zip", "r") as zip_ref:
        zip_ref.extractall("/home/fame/fame/fame/modules/community/processing/mastiff/storage/")
    try:
        mastiff_report = open("/home/fame/fame/fame/modules/community/processing/mastiff/storage/" + file_md5 + "/peinfo-full.txt").read()
    except:
        mastiff_report = open("/home/fame/fame/fame/modules/community/processing/mastiff/storage/" + file_md5 + "/mastiff.log").read()
    return mastiff_report


def post_report(api, misp_report):
    headers = {
    "Authorization": api,
    "Accept": "application/json",
    "content-type": "application/json"
    }
    endpoint = "http://misp_ip/events"
    r = requests.post(endpoint, headers=headers, json=misp_report)
    return r
