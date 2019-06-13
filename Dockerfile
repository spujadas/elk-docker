# Dockerfile for ELK stack
# Elasticsearch, Logstash, Kibana 7.0.1

# Build with:
# docker build -t <repo-user>/elk .

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk <repo-user>/elk

FROM arm32v7/ubuntu
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV \
 REFRESHED_AT=2017-02-28


###############################################################################
#                                INSTALLATION
###############################################################################

### install prerequisites (cURL, gosu, JDK, tzdata)

RUN set -x \
 && apt update -qq \
 && apt install -qqy --no-install-recommends ca-certificates curl gosu tzdata openjdk-8-jdk cron libjna-java vim wget \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && gosu nobody true \
 && set +x

### install Elasticsearch
ARG ELK_VERSION=7.0.1
ENV \
 ES_VERSION=${ELK_VERSION} \
 ES_HOME=/opt/elasticsearch \
 LOGSTASH_VERSION=${ELK_VERSION} \
 LOGSTASH_HOME=/opt/logstash

# note you can't define an env var that references another one in the same block (docker layer)
ENV \
 JAVA_HOME=/usr/lib/jvm/java-8-openjdk-armhf/jre \
 ES_PACKAGE=elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz \
 ES_GID=991 \
 ES_UID=991 \
 ES_PATH_CONF=/etc/elasticsearch \
 ES_PATH_BACKUP=/var/backups \
 KIBANA_VERSION=${ELK_VERSION}
RUN echo "${ELK_VERSION} ${ES_VERSION} https://artifacts.elastic.co/downloads/elasticsearch/${ES_PACKAGE} to ${ES_HOME}"
RUN DEBIAN_FRONTEND=noninteractive \
 && mkdir -p ${ES_HOME}/tmp \
 && curl -O https://artifacts.elastic.co/downloads/elasticsearch/${ES_PACKAGE} \
 && tar xzf ${ES_PACKAGE} -C ${ES_HOME} --strip-components=1 \
 && rm -f ${ES_PACKAGE} \
 && groupadd -r elasticsearch -g ${ES_GID} \
 && useradd -r -s /usr/sbin/nologin -M -c "Elasticsearch service user" -u ${ES_UID} -g elasticsearch elasticsearch \
 && mkdir -p /var/log/elasticsearch ${ES_PATH_CONF} ${ES_PATH_CONF}/scripts /var/lib/elasticsearch ${ES_PATH_BACKUP} \
 && chown -R elasticsearch:elasticsearch ${ES_HOME} /var/log/elasticsearch /var/lib/elasticsearch ${ES_PATH_CONF} ${ES_PATH_BACKUP}


### install Logstash

ENV \
 LOGSTASH_PACKAGE=logstash-${LOGSTASH_VERSION}.tar.gz \
 LOGSTASH_GID=992 \
 LOGSTASH_UID=992 \
 LOGSTASH_PATH_CONF=/etc/logstash \
 LOGSTASH_PATH_SETTINGS=${LOGSTASH_HOME}/config

RUN mkdir ${LOGSTASH_HOME} \
 && curl -O https://artifacts.elastic.co/downloads/logstash/${LOGSTASH_PACKAGE} \
 && tar xzf ${LOGSTASH_PACKAGE} -C ${LOGSTASH_HOME} --strip-components=1 \
 && rm -f ${LOGSTASH_PACKAGE} \
 && groupadd -r logstash -g ${LOGSTASH_GID} \
 && useradd -r -s /usr/sbin/nologin -d ${LOGSTASH_HOME} -c "Logstash service user" -u ${LOGSTASH_UID} -g logstash logstash \
 && mkdir -p /var/log/logstash ${LOGSTASH_PATH_CONF}/conf.d \
 && chown -R logstash:logstash ${LOGSTASH_HOME} /var/log/logstash ${LOGSTASH_PATH_CONF}


### install Kibana

ENV \
 KIBANA_HOME=/opt/kibana \
 KIBANA_PACKAGE=kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz \
 KIBANA_GID=993 \
 KIBANA_UID=993

RUN mkdir ${KIBANA_HOME} \
 && curl -O https://artifacts.elastic.co/downloads/kibana/${KIBANA_PACKAGE} \
 && tar xzf ${KIBANA_PACKAGE} -C ${KIBANA_HOME} --strip-components=1 \
 && rm -f ${KIBANA_PACKAGE} \
 && groupadd -r kibana -g ${KIBANA_GID} \
 && useradd -r -s /usr/sbin/nologin -d ${KIBANA_HOME} -c "Kibana service user" -u ${KIBANA_UID} -g kibana kibana \
 && mkdir -p /var/log/kibana \
 && chown -R kibana:kibana ${KIBANA_HOME} /var/log/kibana


###############################################################################
#                              START-UP SCRIPTS
###############################################################################

### Elasticsearch

ADD ./elasticsearch-init /etc/init.d/elasticsearch
RUN sed -i -e 's#^ES_HOME=$#ES_HOME='$ES_HOME'#' /etc/init.d/elasticsearch \
 && chmod +x /etc/init.d/elasticsearch

### Logstash

ADD ./logstash-init /etc/init.d/logstash
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /etc/init.d/logstash \
 && chmod +x /etc/init.d/logstash

### Kibana

ADD ./kibana-init /etc/init.d/kibana
RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana \
 && chmod +x /etc/init.d/kibana


###############################################################################
#                               CONFIGURATION
###############################################################################

### configure Elasticsearch
ADD ./elasticsearch.yml ${ES_PATH_CONF}/elasticsearch.yml
ADD ./elasticsearch-default /etc/default/elasticsearch
RUN cp ${ES_HOME}/config/log4j2.properties ${ES_HOME}/config/jvm.options \
    ${ES_PATH_CONF} \
 && chown -R elasticsearch:elasticsearch ${ES_PATH_CONF} \
 && chmod -R +r ${ES_PATH_CONF}

### configure Logstash

# certs/keys for Beats and Lumberjack input
RUN mkdir -p /etc/pki/tls/certs && mkdir /etc/pki/tls/private
ADD ./logstash-beats.crt /etc/pki/tls/certs/logstash-beats.crt
ADD ./logstash-beats.key /etc/pki/tls/private/logstash-beats.key

# pipelines
ADD pipelines.yml ${LOGSTASH_PATH_SETTINGS}/pipelines.yml

# filters
ADD ./02-beats-input.conf ${LOGSTASH_PATH_CONF}/conf.d/02-beats-input.conf
ADD ./10-syslog.conf ${LOGSTASH_PATH_CONF}/conf.d/10-syslog.conf
ADD ./11-nginx.conf ${LOGSTASH_PATH_CONF}/conf.d/11-nginx.conf
ADD ./30-output.conf ${LOGSTASH_PATH_CONF}/conf.d/30-output.conf

# patterns
ADD ./nginx.pattern ${LOGSTASH_HOME}/patterns/nginx
RUN chown -R logstash:logstash ${LOGSTASH_HOME}/patterns

# Fix permissions
RUN chmod -R +r ${LOGSTASH_PATH_CONF} ${LOGSTASH_PATH_SETTINGS} \
 && chown -R logstash:logstash ${LOGSTASH_PATH_SETTINGS}

### configure logrotate

ADD ./elasticsearch-logrotate /etc/logrotate.d/elasticsearch
ADD ./logstash-logrotate /etc/logrotate.d/logstash
ADD ./kibana-logrotate /etc/logrotate.d/kibana
RUN chmod 644 /etc/logrotate.d/elasticsearch \
 && chmod 644 /etc/logrotate.d/logstash \
 && chmod 644 /etc/logrotate.d/kibana


### configure Kibana

ADD ./kibana.yml ${KIBANA_HOME}/config/kibana.yml

### ARM workaround
#### jna things
RUN mkdir -p /opt/elasticsearch/lib/tmp
RUN cp /opt/elasticsearch/lib/jna-4.5.1.jar /opt/elasticsearch/lib/tmp/jna-4.5.1.jar
RUN cd /opt/elasticsearch/lib/tmp && jar xf jna-4.5.1.jar
RUN cd /opt/elasticsearch/lib/tmp && rm -f jna-4.5.1.jar
RUN mkdir -p /opt/elasticsearch/lib/tmp/com/sun/jna/linux-arm
RUN cp /usr/lib/arm-linux-gnueabihf/jni/libjnidispatch.system.so /opt/elasticsearch/lib/tmp/com/sun/jna/linux-arm/libjnidispatch.so
RUN cd /opt/elasticsearch/lib/tmp && jar cf ../jna-4.5.1.jar *
RUN rm -rf /opt/elasticsearch/lib/tmp
#### NodeJS for Kibana
RUN cd /root && curl -O https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-armv6l.tar.gz && tar -xvf node-v10.15.2-linux-armv6l.tar.gz
ADD ./kibana.sh /opt/kibana/bin/kibana
RUN chmod a+x /opt/kibana/bin/kibana


###############################################################################
#                                   START
###############################################################################

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5601 9200 9300 5044
VOLUME /var/lib/elasticsearch

CMD [ "/usr/local/bin/start.sh" ]
