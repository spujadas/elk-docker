# Dockerfile to illustrate how Filebeat can be used with nginx
# Filebeat 6.3.0

# Build with:
# docker build -t filebeat-nginx-example .

# Run with:
# docker run -p 80:80 -it --link <elk-container-name>:elk \
#     --name filebeat-nginx-example filebeat-nginx-example

FROM nginx
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV REFRESHED_AT 2016-11-04


###############################################################################
#                                INSTALLATION
###############################################################################

### install Filebeat

ENV FILEBEAT_VERSION 6.3.0


RUN apt-get update -qq \
 && apt-get install -qqy curl \
 && apt-get clean

RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-amd64.deb \
 && dpkg -i filebeat-${FILEBEAT_VERSION}-amd64.deb \
 && rm filebeat-${FILEBEAT_VERSION}-amd64.deb


###############################################################################
#                                CONFIGURATION
###############################################################################

### tweak nginx image set-up

# remove log symlinks
RUN rm /var/log/nginx/access.log /var/log/nginx/error.log


### configure Filebeat

# config file
ADD filebeat.yml /etc/filebeat/filebeat.yml
RUN chmod 644 /etc/filebeat/filebeat.yml

# CA cert
RUN mkdir -p /etc/pki/tls/certs
ADD logstash-beats.crt /etc/pki/tls/certs/logstash-beats.crt

###############################################################################
#                                    DATA
###############################################################################

### add dummy HTML file

COPY html /usr/share/nginx/html


###############################################################################
#                                    START
###############################################################################

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD [ "/usr/local/bin/start.sh" ]
