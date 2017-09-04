#!/usr/bin/python

import daemon
import time
import socket
import re
import subprocess
import sys
from subprocess import check_output

LOGLEVEL = 10

def log (msg = "", level = 10):
    if (LOGLEVEL >= level):
        print msg

def do_something():
    while True:

        hostname = check_output("hostname").rstrip()
        tasks = check_output(["/usr/bin/nslookup tasks.postgresql 2>/dev/null"], shell=True)
        tasks = tasks.split("\n")
#   23  bucardo add sync benchdelta relgroup=alpha dbs=test1:source,test2:target

#        activeContainers = {}
#        activeContainers["data"] = {}
#        activeContainers["data"]["containerList"] = []
        i = 0
        myId = -1
        active = {}
        newactive = {}
        for task in tasks:
            node = re.search("Address\ (\d{1,3}):\ (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\ (.*)$", task)
            if node is not None:
                id = node.group(1)
                ip = node.group(2)
                nodename = node.group(3)
                if hostname == nodename:
                    log ("res5 :%s:%s:" % (hostname, nodename), 10)
                    myId = id
                else:
                    log ("actualmente activa: %s,%s" % (id,ip), 10)
                    newactive[id] = ip

        for key in active:
            if key not in newactive:
                #key ha sido eliminado
                log ("del: /usr/local/bin/bucardo remove sync benchdelta_%s" % key , 10)
                check_output(["/usr/local/bin/bucardo remove sync benchdelta_%s" % key ], shell=True)

        for key in newactive:
            if key not in active:
                #key ha sido anadido
                log ("add: /usr/local/bin/bucardo add sync benchdelta_%s relgroup=alpha dbs=db_1:source,db_%s:target" % (key,key), 10)
                check_output(["/usr/local/bin/bucardo add sync benchdelta_%s relgroup=alpha dbs=db_1:source,db_%s:target" % (key,key) ], shell=True)

        active = newactive


        time.sleep(10)

def killTheContainer():
    # Kill the container!
    subprocess.call("/usr/bin/supervisorctl -c /etc/supervisord.conf shutdown", shell=True)
    sys.exit()


def run():
    with daemon.DaemonContext():
        do_something()


if __name__ == "__main__":
    do_something()
