# Dockerfile to illustrate how Filebeat can be used with nginx
# Filebeat 1.0.1

# Build with:
# docker build -t <repo-user>/filebeat-nginx-example .

# Run with:
# docker run -p 80:80 -it --link <elk-container-name>:elk \
#     --name filebeat-nginx-example <repo-user>/filebeat-nginx-example

FROM nginx
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV REFRESHED_AT 2015-11-28


###############################################################################
#                                INSTALLATION
###############################################################################

### install Filebeat

RUN apt-get update -qq \
 && apt-get install -qqy curl \
 && apt-get clean

RUN curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.0.1_amd64.deb \
 && dpkg -i filebeat_1.0.1_amd64.deb \
 && rm filebeat_1.0.1_amd64.deb


###############################################################################
#                                CONFIGURATION
###############################################################################

### tweak nginx image set-up

# remove log symlinks
RUN rm /var/log/nginx/access.log /var/log/nginx/error.log


### configure Filebeat

# config file
ADD filebeat.yml /etc/filebeat/filebeat.yml

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
