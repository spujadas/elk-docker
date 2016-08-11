FROM sebp/elk

ENV ES_HOME /usr/share/elasticsearch
WORKDIR ${ES_HOME}

ADD 02-s3-input.conf /etc/logstash/conf.d/02-s3-input.conf
ADD 30-output.conf /etc/logstash/conf.d/30-output.conf

RUN gosu elasticsearch bin/plugin install mobz/elasticsearch-head/1.x

ENV LOGSTASH_HOME /opt/logstash
WORKDIR ${LOGSTASH_HOME}
RUN gosu logstash bin/logstash-plugin install logstash-input-s3
