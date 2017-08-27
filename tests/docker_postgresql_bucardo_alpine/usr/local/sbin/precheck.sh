#!/bin/sh

HOSTNAME=`hostname`

if ! [ -d /data/vol/${HOSTNAME} ]
then
  mkdir -p /data/vol/${HOSTNAME}
  ln -s /data/vol/${HOSTNAME} /data/postgresql
  chown postgres /data/postgresql/
  mkdir -p /run/postgresql && chown postgres /run/postgresql
  echo "listen_addresses ='*'" >>/data/postgresql/postgresql.conf
  echo "host    all             all             0/0            md5" >>/data/postgresql/pg_hba.conf
  su postgres -c "/usr/bin/initdb --pgdata /data/postgresql/" 
else
  ln -s /data/vol/${HOSTNAME} /data/postgresql
  chown postgres /data/postgresql/
  mkdir -p /run/postgresql && chown postgres /run/postgresql
fi

supervisorctl start postgresql
sleep 10
if su - postgres -c "echo '\l'|psql"|grep zabbix >/dev/null
then
  su - postgres -c "echo CREATE USER zabbix WITH PASSWORD \'test_zabbix\'\;|psql"
  su - postgres -c "echo CREATE DATABASE zabbix WITH OWNER \'zabbix\' ENCODING \'UTF8\'\;|psql"
  cat /data/build/zabbix/schema.sql |psql -q -U zabbix zabbix
  cat /data/build/zabbix/images.sql |psql -q -U zabbix zabbix
  cat /data/build/zabbix/data.sql |psql -q -U zabbix zabbix
fi
supervisorctl start postcheck.py

