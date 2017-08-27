FROM alpine:3.6
MAINTAINER Alejandro Escanero Blanco <aescanero@gmail.com>

LABEL maintainer="Alejandro Escanero Blanco <aescanero@gmail.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="PostgreSQL Cluster with Bucardo on Alpine OS" \
      org.label-schema.url="https://www.disasterproject.com" \
      org.label-schema.vcs-url="https://github.com/aescanero/dockerevents/docker-postgresql-bucardo-alpine.git"


RUN apk update && apk add -u python py2-pip postgresql bash perl-dbd-pg \
 postgresql-plperl perl-boolean make perl-dbi wget zabbix-agent\
 && pip install supervisor \
 && rm -rf /var/cache/apk/*

RUN mkdir -p /data/pids && mkdir /data/logs && \
  mkdir /data/vol && mkdir /data/build && cd /data/build \
  && wget --no-check-certificate http://bucardo.org/downloads/dbix_safe.tar.gz \
  && tar xvfz dbix_safe.tar.gz && cd DBIx* && perl Makefile.PL && make \
  && make install && cd .. \
  && wget --no-check-certificate http://bucardo.org/downloads/Bucardo-5.4.1.tar.gz \
  && tar -zxvf Bucardo-5.4.1.tar.gz && cd Bucardo-5.4.1 && perl Makefile.PL \
  && make && make install && mkdir -p /var/run/bucardo && mkdir -p /var/log/bucardo

ADD usr/local/sbin/precheck.sh /usr/local/sbin/precheck.sh
ADD usr/local/sbin/postcheck.py /usr/local/sbin/postcheck.py
ADD db/zabbix/data.sql /data/build/zabbix/data.sql
ADD db/zabbix/images.sql /data/build/zabbix/images.sql
ADD db/zabbix/schema.sql /data/build/zabbix/schema.sql
ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

RUN chmod u+x /usr/local/sbin/precheck.sh \
    && chmod u+x /usr/local/sbin/postcheck.py

WORKDIR /data
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
