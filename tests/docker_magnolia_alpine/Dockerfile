FROM alpine:3.6
MAINTAINER Alejandro Escanero Blanco <aescanero@gmail.com>

LABEL maintainer="Alejandro Escanero Blanco <aescanero@gmail.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="Zabbix Agent for Docker on Alpine" \
      org.label-schema.url="https://www.disasterproject.com" \
      org.label-schema.vcs-url="https://github.com/aescanero/dockerevents/docker-postgresql-bucardo-alpine.git"


RUN apk update && apk add -u python py2-pip bash zabbix-agent zabbix-utils\
 && pip install supervisor python-daemon && rm -rf /var/cache/apk/*

RUN mkdir -p /data/pids && mkdir /data/logs && \
  mkdir /data/vol && mkdir /data/build && cd /data/build \
  && cd /data/build && mkdir -p /usr/local/bin && mkdir -p /usr/local/etc \
  && mkdir /etc/zabbix/zabbix_agentd.d && chown zabbix /etc/zabbix/zabbix_agentd.d

ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

WORKDIR /data
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
