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
        for task in tasks:
            node = re.search("Address\ (\d{1,3}):\ (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\ (.*)$", task)
            if node is not None:
                id = node.group(1)
                log ("res3: %s" % id, 10)
                ip = node.group(2)
                log ("res4: %s" % ip, 10)
                nodename = node.group(3)
                if hostname == nodename:
                    log ("res5 :%s:%s:" % (hostname, nodename), 10)
                    myId = id
#                else
#                    check = check_output(["/usr/local/bin/bucardo add sync benchdelta relgroup=alpha dbs=test1:source,test2:target"], shell=True)
#                    update = check_output(["/usr/local/bin/bucardo add sync benchdelta relgroup=alpha dbs=test1:source,test2:target"], shell=True)
                
#                activeContainers["data"]["containerList"][i] = {}
#                activeContainers["data"]["containerList"][i]["ip"] = ip
#                activeContainers["data"]["containerList"][i]["id"] = id
#        log ("myId: %s" % myId, 10)
#        if myId == -1:
#            killTheContainer()
#        else:
#            configureReplication (activeContainers, myId)

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

