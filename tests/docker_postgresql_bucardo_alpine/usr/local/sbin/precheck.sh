#!/bin/sh

n=$(nslookup tasks.postgresql|grep `hostname` |sed s/\://|awk '{print $2}') 2>/dev/null
HOSTNAME=`hostname`
DIRNAME=`echo postgresql.${n}`


if ! [ -d /data/vol/${DIRNAME} ]
then
  mkdir -p /data/vol/${DIRNAME}
  ln -s /data/vol/${DIRNAME} /data/postgresql
  chown postgres /data/postgresql/
  mkdir -p /run/postgresql && chown postgres /run/postgresql
  su postgres -c "/usr/bin/initdb --pgdata /data/postgresql/" 
  echo "listen_addresses ='*'" >>/data/postgresql/postgresql.conf
  echo "host    all             all             0/0            md5" >>/data/postgresql/pg_hba.conf
else
  ln -s /data/vol/${DIRNAME} /data/postgresql
  chown postgres /data/postgresql/
  mkdir -p /run/postgresql && chown postgres /run/postgresql
fi

supervisorctl start postgresql
sleep 10
if ! su - postgres -c "echo '\l'|psql"|grep zabbix >/dev/null
then
  su - postgres -c "echo CREATE USER zabbix WITH PASSWORD \'test_zabbix\'\;|psql"
  su - postgres -c "echo CREATE DATABASE zabbix WITH OWNER \'zabbix\' ENCODING \'UTF8\'\;|psql"
  zcat /data/build/zabbix/zabbix.dump.gz |psql -q -U zabbix zabbix
#  cat /data/build/zabbix/schema.sql |psql -q -U zabbix zabbix
#  cat /data/build/zabbix/images.sql |psql -q -U zabbix zabbix
#  cat /data/build/zabbix/data.sql |psql -q -U zabbix zabbix
#  su - postgres -c "echo INSERT INTO actions VALUES \(7, \'Autodiscover Containers\', 2, 0, 0, 0, \'Auto registration: {HOST.HOST}\', \'Host name: {HOST.HOST}\'\|\|chr\(10\)\|\|\'Host IP: {HOST.IP}\'\|\|chr\(10\)\|\|\'Agent port: {HOST.PORT}\', \'\', \'\', \'\', 1\)\; |psql -U zabbix zabbix"
#  su - postgres -c "echo INSERT INTO operations VALUES \(11, 7, 2, 0, 1, 1, 0, 0\)\; |psql -U zabbix zabbix"
#  su - postgres -c "echo INSERT INTO operations VALUES \(12, 7, 4, 0, 1, 1, 0, 0\)\; |psql -U zabbix zabbix"
#  su - postgres -c "echo INSERT INTO operations VALUES \(13, 7, 6, 0, 1, 1, 0, 0\)\; |psql -U zabbix zabbix"
#  su - postgres -c "echo INSERT INTO opgroup VALUES \(2, 12, 2\)\; |psql -U zabbix zabbix"
#  su - postgres -c "echo INSERT INTO optemplate VALUES \(2, 13, 10001\)\; |psql -U zabbix zabbix"

#  su - postgres -c "echo INSERT INTO actions VALUES (7, \'Autodiscover Containers\', 2, 0, 0, 0, \'Auto registration: {HOST.HOST}\', \'Host name: {HOST.HOST}
#  Host IP: {HOST.IP}
#  Agent port: {HOST.PORT}\', \'\', \'\', \'\', 1)\; |psql"
fi
supervisorctl start postcheck.py

