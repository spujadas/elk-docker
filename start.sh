#!/bin/bash
#
# /usr/local/bin/start.sh
# Start Elasticsearch, Logstash and Kibana services
#
# spujadas 2015-10-09; added initial pidfile removal and graceful termination

# WARNING - This script assumes that the ELK services are not running, and is
#   only expected to be run once, when the container is started.
#   Do not attempt to run this script if the ELK services are running (or be
#   prepared to reap zombie processes).


## handle termination gracefully

_term() {
  echo "Terminating ELK"
  service elasticsearch stop
  service logstash stop
  service kibana stop
  exit 0
}

trap _term SIGTERM


## remove pidfiles in case previous graceful termination failed
# NOTE - This is the reason for the WARNING at the top - it's a bit hackish, 
#   but if it's good enough for Fedora (https://goo.gl/88eyXJ), it's good
#   enough for me :)

rm -f /var/run/elasticsearch/elasticsearch.pid /var/run/logstash.pid \
  /var/run/kibana4.pid

## initialise list of log files to stream in console (initially empty)
OUTPUT_LOGFILES=""

## start services as needed

# Elasticsearch
if [ -z "$ELASTICSEARCH_START" ]; then
  ELASTICSEARCH_START=1
fi
if [ "$ELASTICSEARCH_START" -ne "1" ]; then
  echo "ELASTICSEARCH_START is set to something different from 1, not starting..."
else
  # override ES_MAX_MEM variable if set
  if [ ! -z "$ES_MAX_MEM" ]; then
    sed -i -e 's#^    ES_MAX_MEM=[0-9].*$#    ES_MAX_MEM='$ES_MAX_MEM'#' /usr/share/elasticsearch/bin/elasticsearch.in.sh
  fi

  service elasticsearch start

  # wait for Elasticsearch to start up before either starting Kibana (if enabled)
  # or attempting to stream its log file
  # - https://github.com/elasticsearch/kibana/issues/3077
  counter=0
  while [ ! "$(curl localhost:9200 2> /dev/null)" -a $counter -lt 30  ]; do
    sleep 1
    ((counter++))
    echo "waiting for Elasticsearch to be up ($counter/30)"
  done

  CLUSTER_NAME=$(grep -Po '(?<=^cluster.name: ).*' /etc/elasticsearch/elasticsearch.yml | sed -e 's/^[ \t]*//;s/[ \t]*$//')
  if [ -z "$CLUSTER_NAME" ]; then
     CLUSTER_NAME=elasticsearch
  fi
  OUTPUT_LOGFILES+="/var/log/elasticsearch/${CLUSTER_NAME}.log "
fi

# Logstash
if [ -z "$LOGSTASH_START" ]; then
  LOGSTASH_START=1
fi
if [ "$LOGSTASH_START" -ne "1" ]; then
  echo "LOGSTASH_START is set to something different from 1, not starting..."
else
  # override LS_HEAP_SIZE variable if set
  if [ ! -z "$LS_HEAP_SIZE" ]; then
    sed -i -e 's#^LS_HEAP_SIZE=.*$#LS_HEAP_SIZE='$LS_HEAP_SIZE'#' /etc/init.d/logstash
  fi

  # override LS_OPTS variable if set
  if [ ! -z "$LS_OPTS" ]; then
    sed -i -e 's#^LS_OPTS=.*$#LS_OPTS='$LS_OPTS'#' /etc/init.d/logstash
  fi

  service logstash start
  OUTPUT_LOGFILES+="/var/log/logstash/logstash.log "
fi

# Kibana
if [ -z "$KIBANA_START" ]; then
  KIBANA_START=1
fi
if [ "$KIBANA_START" -ne "1" ]; then
  echo "KIBANA_START is set to something different from 1, not starting..."
else
  service kibana start
  OUTPUT_LOGFILES+="/var/log/kibana/kibana4.log "
fi

# Exit if nothing has been started
if [ "$ELASTICSEARCH_START" -ne "1" ] && [ "$LOGSTASH_START" -ne "1" ] \
  && [ "$KIBANA_START" -ne "1" ]; then
  >&2 echo "No services started. Exiting."
  exit 1
fi

tail -f $OUTPUT_LOGFILES &
wait
