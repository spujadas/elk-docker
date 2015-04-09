#!/bin/bash
#
# /usr/local/bin/start.sh
# Start Elasticsearch, Logstash and Kibana services
#

service elasticsearch start
service logstash start

# wait for elasticsearch to start up - https://github.com/elasticsearch/kibana/issues/3077
counter=0; while [ ! "$(curl localhost:9200 2> /dev/null)" -a $counter -lt 30  ]; do sleep 1; ((counter++)); echo "waiting for Elasticsearch to be up ($counter/30)"; done;

service kibana4 start

tail -f /var/log/elasticsearch/elasticsearch.log
