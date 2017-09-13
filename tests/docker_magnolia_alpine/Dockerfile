FROM tomcat:9-jre8-alpine
MAINTAINER Alejandro Escanero Blanco <aescanero@gmail.com>

LABEL maintainer="Alejandro Escanero Blanco <aescanero@gmail.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="Zabbix Agent for Docker on Alpine" \
      org.label-schema.url="https://www.disasterproject.com" \
      org.label-schema.vcs-url="https://github.com/aescanero/dockerevents/docker-postgresql-bucardo-alpine.git"

ENV MYSQL_JDBC_PACKAGE mysql-connector-java-5.1.44
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_BASE /usr/local/tomcat

RUN apk update && apk add -u python py2-pip bash zabbix-agent zabbix-utils java-postgresql-jdbc wget\
 && pip install supervisor python-daemon && rm -rf /var/cache/apk/*

RUN mkdir -p /data/pids && mkdir /data/logs && \
  mkdir /data/vol && mkdir /data/build && cd /data/build \
  && cd /data/build && mkdir -p /usr/local/bin && mkdir -p /usr/local/etc \
  && mkdir /etc/zabbix/zabbix_agentd.d && chown zabbix /etc/zabbix/zabbix_agentd.d

RUN cd /data/build && wget -O - --no-check-certificate https://dev.mysql.com/get/Downloads/Connector-J/$MYSQL_JDBC_PACKAGE.tar.gz \
  |tar -xvzf - $MYSQL_JDBC_PACKAGE/$MYSQL_JDBC_PACKAGE-bin.jar

RUN ls -l /usr/local/tomcat/lib
RUN ls -l "/data/build/$MYSQL_JDBC_PACKAGE"
RUN mv /data/build/$MYSQL_JDBC_PACKAGE/$MYSQL_JDBC_PACKAGE-bin.jar $CATALINA_HOME/lib

RUN wget -nv --no-check-certificate https://sourceforge.net/projects/magnolia/files/magnolia/Magnolia%20CE%205.5.6/magnolia-community-demo-webapp-5.5.6.war/download?use_mirror=autoselect -O $CATALINA_BASE/webapps/ROOT.war


ADD usr/local/sbin/precheck.sh /usr/local/sbin/precheck.sh
ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
ADD usr/local/tomcat/conf/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

RUN adduser -S tomcat && chown tomcat /usr/local/tomcat -R \
  && chmod u+x /usr/local/sbin/precheck.sh \
  && ln -s /usr/share/java/postgresql-jdbc.jar /usr/local/tomcat/lib/postgresql-jdbc.jar \
  && rm -rf /usr/local/tomcat/webapps/ROOT

WORKDIR /data
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
