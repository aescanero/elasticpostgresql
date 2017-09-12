#!/bin/sh

cd ~/tests/
sudo docker build -t elasticpostgresql:psql_v1 -f docker_postgresql_bucardo_alpine/Dockerfile docker_postgresql_bucardo_alpine/.
sudo docker build -t elasticpostgresql:zabbix_v1 -f docker_zabbix/Dockerfile docker_zabbix/.
sudo docker build -t elasticpostgresql:docker_tomcat_alpine_v1 -f docker_tomcat_alpine/Dockerfile docker_tomcat_alpine/.
sudo docker network create -d overlay registrynetwork
sudo docker service create --detach=true --endpoint-mode vip --network registrynetwork --publish 5000:5000 --restart-condition any --name registry registry:2
sudo docker tag elasticpostgresql:psql_v1 localhost:5000/elasticpostgresql:psql_v1
sudo docker push localhost:5000/elasticpostgresql:psql_v1
sudo docker tag elasticpostgresql:zabbix_v1 localhost:5000/elasticpostgresql:zabbix_v1
sudo docker push localhost:5000/elasticpostgresql:zabbix_v1
sudo docker tag elasticpostgresql:docker_tomcat_alpine_v1 localhost:5000/elasticpostgresql:docker_tomcat_alpine_v1
sudo docker push localhost:5000/elasticpostgresql:docker_tomcat_alpine_v1

sudo docker stack deploy demo -c docker-compose-test.yml
sudo docker stack ps demo

#sudo docker build -t elasticpostgresql:psql_v2 -f docker_postgresql_pgpool_alpine/Dockerfile docker_postgresql_pgpool_alpine/.
sudo docker exec -i -t `sudo docker ps -a|grep psql|awk '{print $1}'|tail -1` /bin/bash
