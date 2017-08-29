FROM alpine:3.6
MAINTAINER Alejandro Escanero Blanco <aescanero@gmail.com>

LABEL maintainer="Alejandro Escanero Blanco <aescanero@gmail.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="Zabbix Server for monitor" \
      org.label-schema.url="https://www.disasterproject.com" \
      org.label-schema.vcs-url="https://github.com/aescanero/dockerevents/docker-zabbix.git"


RUN apk update && apk add -u python py2-pip zabbix-pgsql zabbix-setup \
 zabbix-utils zabbix-agent 

RUN apk add zabbix-webif php7-fpm nginx php7-pgsql php7-session php7-mbstring php7-simplexml\
 && pip install supervisor && rm -rf /var/cache/apk/*

RUN sed -i -e 's/post_max_size = [0-9]*M/post_max_size = 16M/' \
  -e 's/post_max_size = [0-9]*/post_max_size = 300/' \
  -e 's/max_input_time = [0-9]*/max_input_time = 300/' \
  -e 's/max_execution_time = [0-9]*/max_execution_time = 300/' \
  /etc/php7/php.ini && echo 'date.timezone = "UTC";' >>/etc/php7/php.ini

RUN mkdir -p /data/pids && mkdir -p /data/logs/nginx && mkdir -p /run/nginx \
  && adduser -S www && chown nginx /run/nginx /data/logs/nginx \
  && mkdir -p /data/logs/php7

ADD etc/nginx/conf.d/nginx-site.conf /etc/nginx/conf.d/default.conf
ADD etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD etc/php7/php-fpm.conf /etc/php7/php-fpm.conf
ADD etc/php7/php-fpm.d/www.conf /etc/php7/php-fpm.d/www.conf
ADD etc/supervisord.conf /etc/supervisord.conf
ADD zabbix/zabbix.conf.php /usr/share/webapps/zabbix/conf/zabbix.conf.php
ADD etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf
ADD etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

RUN chmod 644 /usr/share/webapps/zabbix/conf/zabbix.conf.php

WORKDIR /data
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
