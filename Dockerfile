FROM phusion/baseimage
MAINTAINER Sebastien Pujadas <sebastien@my_surname.net>
ENV REFRESHED_AT 2015-02-22

###############################################################################
#                                INSTALLATION
###############################################################################

### install elasticsearch and logstash

RUN apt-get update -qq && apt-get install -qqy curl

RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main > /etc/apt/sources.list.d/elasticsearch.list

RUN echo deb http://packages.elasticsearch.org/logstash/1.4/debian stable main > /etc/apt/sources.list.d/logstash.list

RUN apt-get update -qq && apt-get install -qqy openjdk-7-jdk elasticsearch logstash=1.4.2-1-2c0f5a1


### install kibana

RUN mkdir /opt/kibana \
	&& curl -O https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz \
	&& tar xzf kibana-4.0.1-linux-x64.tar.gz -C /opt/kibana --strip-components=1 \
	&& rm -f kibana-4.0.1-linux-x64.tar.gz


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
