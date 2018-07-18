#!/usr/bin/python2.7

import MySQLdb
from sshtunnel import SSHTunnelForwarder
import mysql.connector
from mysql.connector import (connection)

def get_api_key():
    #Gets MISP API key
    SQL_HOST='misp_ip'
    api_file = open("/home/fame/.donotopen", "w")
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

get_api_key()
