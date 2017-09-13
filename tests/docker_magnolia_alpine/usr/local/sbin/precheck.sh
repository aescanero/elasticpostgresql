#!/bin/sh

sleep 5
supervisorctl start tomcat &
supervisorctl start zabbix_agentd &
