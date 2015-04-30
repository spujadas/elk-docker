# Dockerfile for ELK stack
# Elasticsearch 1.5.2, Logstash 1.4.2, Kibana 4.0.2

# Build with:
# docker build . -t <repo-user>/elk

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk <repo-user>/elk

FROM phusion/baseimage
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV REFRESHED_AT 2015-04-30

###############################################################################
#                                INSTALLATION
###############################################################################

### install elasticsearch and logstash

RUN apt-get update -qq \
 && apt-get install -qqy curl

RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo deb http://packages.elasticsearch.org/elasticsearch/1.5/debian stable main > /etc/apt/sources.list.d/elasticsearch.list

RUN echo deb http://packages.elasticsearch.org/logstash/1.4/debian stable main > /etc/apt/sources.list.d/logstash.list

RUN apt-get update -qq \
 && apt-get install -qqy \
		elasticsearch \
		logstash=1.4.2-1-2c0f5a1 \
		openjdk-7-jdk


### install kibana

ENV KIBANA_HOME /opt/kibana

RUN mkdir ${KIBANA_HOME} \
 && curl -O https://download.elasticsearch.org/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz \
 && tar xzf kibana-4.0.2-linux-x64.tar.gz -C ${KIBANA_HOME} --strip-components=1 \
 && rm -f kibana-4.0.2-linux-x64.tar.gz

ADD ./kibana4-init /etc/init.d/kibana4
RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana4 \
 && chmod +x /etc/init.d/kibana4 \
 && groupadd -r kibana \
 && useradd -r -s /usr/sbin/nologin -d ${KIBANA_HOME} -c "Kibana service user" -g kibana kibana \
 && chown -R kibana:kibana ${KIBANA_HOME}


###############################################################################
#                               CONFIGURATION
###############################################################################

### configure and start elasticsearch

ADD ./elasticsearch.yml /etc/elasticsearch/elasticsearch.yml


### configure and start logstash

# cert/key
RUN mkdir -p /etc/pki/tls/certs && mkdir /etc/pki/tls/private
ADD ./logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
ADD ./logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key

# filters
ADD ./01-lumberjack-input.conf /etc/logstash/conf.d/01-lumberjack-input.conf
ADD ./10-syslog.conf /etc/logstash/conf.d/10-syslog.conf
ADD ./11-nginx.conf /etc/logstash/conf.d/11-nginx.conf
ADD ./30-lumberjack-output.conf /etc/logstash/conf.d/30-lumberjack-output.conf

# patterns
ADD ./nginx.pattern /opt/logstash/patterns/nginx
RUN chown logstash:logstash /opt/logstash/patterns/*


###############################################################################
#                                   START
###############################################################################

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5601 9200 5000

CMD [ "/usr/local/bin/start.sh" ]
