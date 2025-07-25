# Dockerfile to illustrate how Filebeat can be used with nginx
# Filebeat OSS 8.14.3

# Build with:
# docker build -t filebeat-nginx-example .

# Run with:
# docker run -p 80:80 -it --link <elk-container-name>:elk \
#     --name filebeat-nginx-example filebeat-nginx-example

FROM nginx
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV REFRESHED_AT 2020-10-02


###############################################################################
#                                INSTALLATION
###############################################################################

### install Filebeat

<<<<<<< HEAD
ENV FILEBEAT_VERSION 9.0.4
ENV FILEBEAT_BASE_VERSION 9.0.4
=======
ENV FILEBEAT_VERSION oss-8.14.3
ENV FILEBEAT_BASE_VERSION 9.0.4
>>>>>>> 7b5a7e1625b123c49d1a817cad15725b10f23144


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

# create template based on filebeat version (assumption: it is the same version as elasticsearch version)
RUN filebeat export template --es.version ${FILEBEAT_BASE_VERSION} > /etc/filebeat/filebeat.template.json

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
