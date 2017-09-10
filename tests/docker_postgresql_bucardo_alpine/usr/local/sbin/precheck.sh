#!/bin/sh

n=$(nslookup tasks.postgresql 2>/dev/null|grep `hostname` |sed s/\://|awk '{print $2}')
echo $n
myip=$(nslookup tasks.postgresql 2>/dev/null|grep `hostname` |sed s/\://|awk '{print $3}')
echo $myip
mynet=$(echo -n $myip|cut -d\. -f -3)".0/24"
echo $mynet
restip=$(nslookup tasks.postgresql 2>/dev/null|sed s/\://|awk '{print $3}'|grep -v ^$|grep -v $myip|tr '\n' ' ')
echo $restip
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
  echo "host    zabbix             all             $mynet            trust" >>/data/postgresql/pg_hba.conf
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
#echo "Hostname=$DIRNAME" >>/etc/zabbix/zabbix_agentd.conf
echo "Include=/etc/zabbix/zabbix_agentd.d/" >>/etc/zabbix/zabbix_agentd.conf
supervisorctl start zabbix_agentd &

if bucardo show 2>&1 |grep FATAL >/dev/null
then
cat > $HOME/.bucardorc <<EOL  
dbhost=127.0.0.1
dbname=bucardo
dbport=5432
dbuser=bucardo
bdpass=bucardo
batch=1
verbose=1
EOL
  bucardo install --bucardorc $HOME/.bucardorc --batch
  su - postgres -c "echo ALTER ROLE bucardo PASSWORD \'bucardo\'\;|psql"
  echo "*:5432:*:bucardo:bucardo" >$HOME/.pgpass
  #bucardo add db db_${n} dbname=zabbix
  nslookup tasks.postgresql 2>/dev/null|sed s/\://|grep -v ^$|grep -v tasks \
  |awk '{print "/usr/local/bin/bucardo add db db_"$2" dbhost="$3" dbname=zabbix --force"}' \
  |sed s/"$myip"/'127.0.0.1'/|while read l
  do
    echo "$l"
    $l
  done
#check tables with primary key
  tables=`echo "select concat(tc.table_schema,'.',tc.table_name) as table from information_schema.table_constraints tc where tc.constraint_type = 'PRIMARY KEY' group by tc.table_schema,tc.table_name;"|psql -U zabbix zabbix -t|tr '\n' ' '`
  echo bucardo add table $tables db=db_${n} -T history herd=alpha
  bucardo add table $tables db=db_1 -T history herd=alpha
#  echo bucardo add all tables db=db_${n} relgroup=alpha
#  bucardo add all tables db=db_${n} relgroup=alpha
  nslookup tasks.postgresql 2>/dev/null |sed s/\://|grep -v ^$ |grep -v tasks \
  |grep -v ^"Address $n" \
  |awk '{print "/usr/local/bin/bucardo add sync benchdelta_"$2" relgroup=alpha dbs=db_#:source,db_"$2":target"}' \
  |sed s/\#/$n/|while read l
  do
    echo "$l"
    $l
  done
  bucardo start  
fi

supervisorctl start postcheck.py
