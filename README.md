# elasticpostgresql
Elastic PostgreSQL MultiMaster Replicatión with Bucardo and Zabbix to monitor perfomance


Step 1: Creating a base box for faster swarm testing
======================================================
Include:
- docker last stable release
- docker compose via python-pip
- based in ubuntu zesty
- add glusterfs packages
- add zabbix agent

Create a vagrant box for docker testing with

```
$ git clone -b base_docker https://github.com/aescanero/base_docker.git
$ cd base_docker
~/base_docker$ vagrant plugin install vagrant-vbguest
~/base_docker$ vagrant up
~/base_docker$ vagrant halt
~/base_docker$ vagrant package --output base_docker.box
~/base_docker$ vagrant box add base_docker.box --name tests/base_docker
~/base_docker$ vagrant destroy -f
```

Step 2: Creating Swarm nodes
======================================================
Five nodes 


```
$ if [ -d elasticpostgresql ];then rm -rf elasticpostgresql;fi
$ git clone https://github.com/aescanero/elasticpostgresql elasticpostgresql
$ cd elasticpostgresql
~/elasticpostgresql$ vagrant up
~/elasticpostgresql$ for i in swarm-node-1 swarm-node-2 swarm-node-3; do vagrant ssh $i -c "sudo mount /persistent-storage";done
~/elasticpostgresql$ vagrant push
```

