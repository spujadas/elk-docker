# Elasticsearch, Logstash, Kibana (ELK) Docker image documentation

This web page documents how to use the [sebp/elk](https://hub.docker.com/r/sebp/elk/) Docker image, which provides a convenient centralised log server and log management web interface, by packaging [Elasticsearch](http://www.elasticsearch.org/), [Logstash](http://logstash.net/), and [Kibana](http://www.elasticsearch.org/overview/kibana/), collectively known as ELK.

### Contents ###

- [Installation](#installation)
- [Usage](#usage)
	- [Running the container using Docker Compose](#running-with-docker-compose)
	- [Creating a dummy log entry](#creating-dummy-log-entry)
- [Forwarding logs](#forwarding-logs)
	- [Forwarding logs with Filebeat](#forwarding-logs-filebeat)
	- [Forwarding logs with Logstash forwarder](#forwarding-logs-logstash-forwarder)
	- [Linking a Docker container to the ELK container](#linking-containers)
- [Building the image](#building-image)
- [Extending the image](#extending-image)
	- [Installing Elasticsearch plugins](#installing-elasticsearch-plugins)
	- [Installing Logstash plugins](#installing-logstash-plugins)
- [Storing log data](#storing-log-data)
- [Setting up an Elasticsearch cluster](#elasticsearch-cluster)
	- [Running Elasticsearch nodes on different hosts](#elasticsearch-cluster-different-hosts)
	- [Running Elasticsearch nodes on a single host](#elasticsearch-cluster-single-host)
	- [Optimising your Elasticsearch cluster](#optimising-elasticsearch-cluster)
- [Security considerations](#security-considerations)
- [References](#references)
- [About](#about)

## Installation <a name="installation"></a>

Install [Docker](https://docker.com/), either using a native package (Linux) or wrapped in a virtual machine (Windows, OS X – e.g. using [Boot2Docker](http://boot2docker.io/) or [Vagrant](https://www.vagrantup.com/)).

To pull this image from the [Docker registry](https://hub.docker.com/r/sebp/elk/), open a shell prompt and enter:

	$ sudo docker pull sebp/elk

**Note** – This image has been built automatically from the source files in the [source Git repository on GitHub](https://github.com/spujadas/elk-docker). If you want to build the image yourself, see the *[Building the image](#building-image)* section below.

**Note** – The last image using the Elasticsearch 1.x and Logstash 1.x branches can be pulled using `sudo docker pull sebp/elk:E1L1K4`. The versions of the ELK components in that image are: Elasticsearch 1.7.3, Logstash 1.5.5, and Kibana 4.1.2.

## Usage <a name="usage"></a>

Run the container from the image with the following command:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 5000:5000 -it --name elk sebp/elk

This command publishes the following ports, which are needed for proper operation of the ELK stack:

- 5601 (Kibana web interface).
- 9200 (Elasticsearch JSON interface).
- 5044 (Logstash Beats interface, receives logs from Beats such as Filebeat – see the *[Forwarding logs](#forwarding-logs)* section below).
- 5000 (Logstash Lumberjack interface, receives logs from Logstash forwarders – see the *[Forwarding logs](#forwarding-logs)* section below).

**Note** – The image also exposes Elasticsearch's transport interface on port 9300. Use the `-p 9300:9300` option with the `docker` command above to publish it.

The figure below shows how the pieces fit together.

![](http://i.imgur.com/wDertsM.png)

Access Kibana's web interface by browsing to `http://<your-host>:5601`, where `<your-host>` is the hostname or IP address of the host Docker is running on (see note), e.g. `localhost` if running a local native version of Docker, or the IP address of the virtual machine if running a VM-hosted version of Docker (see note).

**Note** – To configure and/or find out the IP address of a VM-hosted Docker installation, see [https://docs.docker.com/installation/windows/](https://docs.docker.com/installation/windows/) (Windows) and [https://docs.docker.com/installation/mac/](https://docs.docker.com/installation/mac/) (OS X) for guidance if using Boot2Docker. If you're using [Vagrant](https://www.vagrantup.com/), you'll need to set up port forwarding (see [https://docs.vagrantup.com/v2/networking/forwarded_ports.html](https://docs.vagrantup.com/v2/networking/forwarded_ports.html).

You can stop the container with `^C`, and start it again with `sudo docker start elk`.

As from Kibana version 4.0.0, you won't be able to see anything (not even an empty dashboard) until something has been logged (see the *[Creating a dummy log entry](#creating-dummy-log-entry)* sub-section below on how to test your set-up, and the *[Forwarding logs](#forwarding-logs)* section on how to forward logs from regular applications).

### Running the container using Docker Compose <a name="running-with-docker-compose"></a>

If you're using [Docker Compose](https://docs.docker.com/compose/) to manage your Docker services (and if not you really should as it will make your life much easier!), then you can create an entry for the ELK Docker image by adding the following lines to your `docker-compose.yml` file:

	elk:
	  image: sebp/elk
	  ports:
	    - "5601:5601"
	    - "9200:9200"
	    - "5044:5044"
	    - "5000:5000"

You can then start the ELK container like this:

	$ sudo docker-compose up elk

### Creating a dummy log entry <a name="creating-dummy-log-entry"></a>

If you haven't got any logs yet and want to manually create a dummy log entry for test purposes (for instance to see the dashboard), first start the container as usual (`sudo docker run ...` or `docker-compose up ...`).

In another terminal window, find out the name of the container running ELK, which is displayed in the last column of the output of the `sudo docker ps` command.

	$ sudo docker ps
	CONTAINER ID        IMAGE                  ...   NAMES
	86aea21cab85        elkdocker_elk:latest   ...   elkdocker_elk_1

Open a shell prompt in the container and type (replacing `<container-name>` with the name of the container, e.g. `elkdocker_elk_1` in the example above):

	$ sudo docker exec -it <container-name> /bin/bash

At the prompt, enter:

_(since Logstash 2.0.0)_

	# /opt/logstash/bin/logstash -e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] } }'

_(before Logstash 2.0.0)_

	# /opt/logstash/bin/logstash -e 'input { stdin { } } output { elasticsearch { host => localhost } }'

Wait for Logstash to start (as indicated by the message `Logstash startup completed`), then type some dummy text followed by Enter to create a log entry:

	this is a dummy entry

**Note** – You can create as many entries as you want. Use `^C` to go back to the bash prompt.

If you browse to `http://<your-host>:9200/_search?pretty` (e.g. [http://localhost:9200/_search?pretty](http://localhost:9200/_search?pretty) for a local native instance of Docker) you'll see that Elasticsearch has indexed the entry:

	{
	  ...
	  "hits": {
	    ...
	    "hits": [ {
	      "_index": "logstash-...",
	      "_type": "logs",
	      ...
	      "_source": { "message": "this is a dummy entry", "@version": "1", "@timestamp": ... }
	    } ]
	  }
	}

You can now browse to Kibana's web interface at `http://<your-host>:5601` (e.g. [http://localhost:5601](http://localhost:5601) for a local native instance of Docker).

Make sure that the drop-down "Time-field name" field is pre-populated with the value `@timestamp`, then click on "Create", and you're good to go.

## Forwarding logs <a name="forwarding-logs"></a>

Forwarding logs from a host relies on a forwarding agent that collects logs (e.g. from log files, from the syslog daemon) and sends them to our instance of Logstash.

The forwarding agent that was originally used with Logstash was Logstash forwarder, but with the introduction of the [Beats platform](https://www.elastic.co/products/beats) it will be phased out in favour of Filebeat, which should now be the preferred option. The two approaches are described below.

### Forwarding logs with Filebeat <a name="forwarding-logs-filebeat"></a>

Install [Filebeat](https://www.elastic.co/products/beats/filebeat) on the host you want to collect and forward logs from (see the *[References](#references)* section below for links to detailed instructions).

**Note** – The `nginx-filebeat` subdirectory of the [source Git repository on GitHub](https://github.com/spujadas/elk-docker) contains a sample `Dockerfile` which enables you to create a Docker image that implements the steps below.

Here is a sample `/etc/filebeat/filebeat.yml` configuration file for Filebeat, that forwards syslog and authentication logs, as well as [nginx](http://nginx.org/) logs.

	output:
	  logstash:
	    enabled: true
	    hosts:
	      - elk:5044
	    tls:
		  certificate_authorities:
      	    - /etc/pki/tls/certs/logstash-beats.crt
	    timeout: 15
	
	filebeat:
	  prospectors:
	    -
	      paths:
	        - /var/log/syslog
	        - /var/log/auth.log
	      document_type: syslog
	    -
	      paths:
	        - "/var/log/nginx/*.log"
	      document_type: nginx-access

In the sample configuration file, make sure that you replace `elk` in `elk:5044` with the hostname or IP address of the ELK-serving host.

You'll also need to copy the `logstash-beats.crt` file (which contains the CA certificate – or server certificate as the certificate is self-signed – for Logstash's Beats input plugin) from the ELK image to `/etc/pki/tls/certs/logstash-beats.crt`.

**Note** – The ELK image includes configuration items (`/etc/logstash/conf.d/11-nginx.conf` and `/opt/logstash/patterns/nginx`) to parse nginx access logs, as forwarded by the Filebeat instance above.

Before starting Filebeat for the first time, run this command (replace `elk` with the appropriate hostname) to load the default index template in Elasticsearch:

		curl -XPUT 'http://elk:9200/_template/filebeat?pretty' -d@/etc/filebeat/filebeat.template.json

Start Filebeat:

		sudo /etc/init.d/filebeat start

### Forwarding logs with Logstash forwarder <a name="forwarding-logs-logstash-forwarder"></a>

**Note** – This approach is deprecated: [using Filebeat](#forwarding-logs-filebeat) is now the preferred way to forward logs.

Install [Logstash forwarder](https://github.com/elasticsearch/logstash-forwarder) on the host you want to collect and forward logs from (see the *[References](#references)* section below for links to detailed instructions).

Here is a sample configuration file for Logstash forwarder, that forwards syslog and authentication logs, as well as [nginx](http://nginx.org/) logs.

	{
	  "network": {
	    "servers": [ "elk:5000" ],
	    "timeout": 15,
	    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"
	  },
	  "files": [
	    {
	      "paths": [
	        "/var/log/syslog",
	        "/var/log/auth.log"
	       ],
	      "fields": { "type": "syslog" }
	    },
	    {
	      "paths": [
	        "/var/log/nginx/access.log"
	       ],
	      "fields": { "type": "nginx-access" }
	    }
	   ]
	}

By default (see `/etc/init.d/logstash-forwarder` if you need to tweak anything):

- The Logstash forwarder configuration file must be located in `/etc/logstash-forwarder`.
- The Logstash forwarder needs a syslog daemon (e.g. rsyslogd, syslog-ng) to be running.

In the sample configuration file, make sure that you replace `elk` in `elk:5000` with the hostname or IP address of the ELK-serving host.

You'll also need to copy the `logstash-forwarder.crt` file (which contains the CA certificate – or server certificate as the certificate is self-signed – for Logstash's Lumberjack input plugin) from the ELK image to `/etc/pki/tls/certs/logstash-forwarder.crt`.

Lastly, you'll need to alter Logstash's Elasticsearch output plugin configuration (in `30-output.conf`) to remove the reference to the dynamic field `%{[@metadata][beat]}` in the `index` configuration option, as this field implies that Beat is being used to forward logs. A minimal configuration file such as the following would work fine:

	output {
	  elasticsearch { hosts => ["localhost"] }
	  stdout { codec => rubydebug }
	}


**Note** – The ELK image includes configuration items (`/etc/logstash/conf.d/11-nginx.conf` and `/opt/logstash/patterns/nginx`) to parse nginx access logs, as forwarded by the Logstash forwarder instance above.

### Linking a Docker container to the ELK container <a name="linking-containers"></a>

If you want to forward logs from a Docker container to the ELK container, then you need to link the two containers.

**Note** – The log-emitting Docker container must have a Logstash forwarder agent running in it for this to work.

First of all, give the ELK container a name (e.g. `elk`) using the `--name` option:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 5000:5000 -it --name elk sebp/elk

Then start the log-emitting container with the `--link` option (replacing `your/image` with the name of the Logstash-forwarder-enabled image you're forwarding logs from):

	$ sudo docker run -p 80:80 -it --link elk:elk your/image

From the perspective of the log emitting container, the ELK container is now known as `elk`, which is the hostname to be used in the `logstash-forwarder` configuration file.

With Compose here's what example entries for a (locally built log-generating) container and an ELK container might look like in the `docker-compose.yml` file.

	yourapp:
	  image: your/image
	  ports:
	    - "80:80"
	  links:
	    - elk

	elk:
	  image: sebp/elk
	  ports:
	    - "5601:5601"
	    - "9200:9200"
	    - "5044:5044"
	    - "5000:5000"

## Building the image <a name="building-image"></a>

To build the Docker image from the source files, first clone the [Git repository](https://github.com/spujadas/elk-docker), go to the root of the cloned directory (i.e. the directory that contains `Dockerfile`), and:

- If you're using the vanilla `docker` command then run `sudo docker build -t <repository-name> .`, where `<repository-name>` is the repository name to be applied to the image, which you can then use to run the image with the `docker run` command.

- If you're using Compose then run `sudo docker-compose build elk`, which uses the `docker-compose.yml` file from the source repository to build the image. You can then run the built image with `sudo docker-compose up`.


## Extending the image <a name="extending-image"></a>

To extend the image, you can either fork the source Git repository and hack away, or – more in the spirit of the Docker philosophy – use the image as a base image and build on it, adding files (e.g. configuration files to process logs sent by log-producing applications, plugins for Elasticsearch) and overwriting files (e.g. configuration files, certificate and private key files) as required.

To create a new image based on this base image, you want your `Dockerfile` to include:

	FROM sebp/elk

followed by instructions to extend the image (see Docker's [Dockerfile Reference page](https://docs.docker.com/reference/builder/) for more information).

The next few subsections present some typical use cases.

### Installing Elasticsearch plugins <a name="installing-elasticsearch-plugins"></a>

Elasticsearch's home directory in the image is `/usr/share/elasticsearch`, its [plugin management script](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-plugins.html) (`plugin`) resides in the `bin` subdirectory, and plugins are installed in `plugins`.

A `Dockerfile` like the following will extend the base image and install Elastic HQ, a management and monitoring plugin for Elasticsearch, using `plugin`.

	FROM sebp/elk

	ENV ES_HOME /usr/share/elasticsearch
	WORKDIR ${ES_HOME}

	RUN bin/plugin -i royrusso/elasticsearch-HQ

You can now build the new image (see the *[Building the image](#building-image)* section above) and run the container in the same way as you did with the base image. The Elastic HQ interface will be accessible at `http://<your-host>:9200/_plugin/HQ/` (e.g. [http://localhost:9200/_plugin/HQ/](http://localhost:9200/_plugin/HQ/) for a local native instance of Docker).

### Installing Logstash plugins <a name="installing-logstash-plugins"></a>

The name of Logstash's home directory in the image is stored in the `LOGSTASH_HOME` environment variable (which is set to `/opt/logstash` in the base image). Logstash's plugin management script (`plugin`) is located in the `bin` subdirectory.

The following `Dockerfile` can be used to extend the base image and install the [RSS input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-rss.html):

	FROM sebp/elk

	WORKDIR ${LOGSTASH_HOME}
	RUN bin/plugin install logstash-input-rss

See the *[Building the image](#building-image)* section above for instructions on building the new image. You can then run a container based on this image using the same command line as the one in the *[Usage](#usage)* section.

## Storing log data <a name="storing-log-data"></a>

In order to keep log data across container restarts, this image mounts `/var/lib/elasticsearch` — which is the directory that Elasticsearch stores its data in — as a volume.

You may however want to use a dedicated data volume to store this log data, for instance to facilitate back-up and restore operations.

One way to do this with the `docker` command-line tool is to first create a named container called `elk_data` with a bound Docker volume by using the `-v` option:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -v /var/lib/elasticsearch --name elk_data sebp/elk

You can now reuse the persistent volume from that container using the `--volumes-from` option:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 --volumes-from elk_data --name elk sebp/elk

**Note** – By design, Docker never deletes a volume automatically (e.g. when no longer used by any container). Whilst this avoids accidental data loss, it also means that things can become messy if you're not managing your volumes properly (i.e. using the `-v` option when removing containers with `docker rm` to also delete the volumes... bearing in mind that the actual volume won't be deleted as long as at least one container is still referencing it, even if it's not running). As of this writing, managing Docker volumes can be a bit of a headache, so you might want to have a look at [docker-cleanup-volumes](https://github.com/chadoe/docker-cleanup-volumes), a shell script that deletes unused Docker volumes.

See Docker's page on [Managing Data in Containers](https://docs.docker.com/userguide/dockervolumes/) and Container42's [Docker In-depth: Volumes](http://container42.com/2014/11/03/docker-indepth-volumes/) page for more information on managing data volumes.

## Setting up an Elasticsearch cluster <a name="elasticsearch-cluster"></a>

The ELK image can be used to run an Elasticsearch cluster, either on [separate hosts](#elasticsearch-cluster-different-hosts) or (mainly for test purposes) on a [single host](#elasticsearch-cluster-single-host), as described below.

For more (non-Docker-specific) information on setting up an Elasticsearch cluster, see the [Life Inside a Cluster section](https://www.elastic.co/guide/en/elasticsearch/guide/current/distributed-cluster.html) section of the Elasticsearch definitive guide.

### Running Elasticsearch nodes on different hosts <a name="elasticsearch-cluster-different-hosts"></a>

To run nodes on different hosts, you'll need to update Elasticsearch's `/etc/elasticsearch/elasticsearch.yml` file in the Docker image to configure the [zen discovery module](http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html) as needed for the nodes to find each other. Specifically, you need to add a `discovery.zen.ping.unicast.hosts` directive to point to the IP addresses or hostnames of hosts that should be polled to perform discovery when Elasticsearch is started on each node.

As an example, start an ELK container as usual on one host, which will act as the first master. Let's assume that the host is called *elk-master.example.com*.

Have a look at the cluster's health:

	$ curl http://elk-master.example.com:9200/_cluster/health?pretty
	{
	  "cluster_name" : "elasticsearch",
	  "status" : "yellow",
	  "timed_out" : false,
	  "number_of_nodes" : 1,
	  "number_of_data_nodes" : 1,
	  "active_primary_shards" : 6,
	  "active_shards" : 6,
	  "relocating_shards" : 0,
	  "initializing_shards" : 0,
	  "unassigned_shards" : 6,
	  "delayed_unassigned_shards" : 6,
	  "number_of_pending_tasks" : 0,
	  "number_of_in_flight_fetch" : 0,
	  "task_max_waiting_in_queue_millis" : 0,
	  "active_shards_percent_as_number" : 50.0
	}

This shows that only one node is up at the moment, and the `yellow` status indicates that all primary shards are active, but not all replica shards are active.

Then, on another host, create a file named `elasticsearch-slave.yml` (let's say it's in `/home/elk`), with the following contents:

	network.host: 0.0.0.0
	discovery.zen.ping.unicast.hosts: ["elk-master.example.com"]

You can now start an ELK container that uses this configuration file, using the following command (which mounts the configuration files on the host into the container):

	$ sudo docker run -it --rm=true -p 9200:9200 \
	  -v /home/elk/elasticsearch-slave.yml:/etc/elasticsearch/elasticsearch.yml \
	  sebp/elk

Once Elasticsearch is up, displaying the cluster's health on the original host now shows:

	$ curl http://elk-master.example.com:9200/_cluster/health?pretty
	{
	  "cluster_name" : "elasticsearch",
	  "status" : "green",
	  "timed_out" : false,
	  "number_of_nodes" : 2,
	  "number_of_data_nodes" : 2,
	  "active_primary_shards" : 6,
	  "active_shards" : 12,
	  "relocating_shards" : 0,
	  "initializing_shards" : 0,
	  "unassigned_shards" : 0,
	  "delayed_unassigned_shards" : 0,
	  "number_of_pending_tasks" : 0,
	  "number_of_in_flight_fetch" : 0,
	  "task_max_waiting_in_queue_millis" : 0,
	  "active_shards_percent_as_number" : 100.0
	}

### Running Elasticsearch nodes on a single host <a name="elasticsearch-cluster-single-host"></a>

Setting up Elasticsearch nodes to run on a single host is similar to running the nodes on different hosts, but the containers need to be linked in order for the nodes to discover each other.

Start the first node using the usual `docker` command on the host:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 5000:5000 -it --name elk sebp/elk

Now, create a basic `elasticsearch-slave.yml` file containing the following lines:

	network.host: 0.0.0.0
	discovery.zen.ping.unicast.hosts: ["elk"]

Start a node using the following command:

	$ sudo docker run -it --rm=true \
	  -v /var/sandbox/elk-docker/elasticsearch-slave.yml:/etc/elasticsearch/elasticsearch.yml \
	  --link elkdocker_elk_1:elk-master elkdocker_elk

Note that Elasticsearch's port is not published to the host's port 9200, as it was already published by the initial ELK container.

### Optimising your Elasticsearch cluster <a name="optimising-elasticsearch-cluster"></a>

You can use the ELK image as is to run an Elasticsearch cluster, especially if you're just testing, but to optimise your set-up, you may want to have:

- One node running the complete ELK stack, using the ELK image as is.

- Several nodes running _only_ Elasticsearch.

	To run Elasticsearch only, an easy way to proceed is to extend the ELK image to alter the `start.sh` script and only start Elasticsearch. Something minimal like this should do the trick:
	
		#!/bin/bash
		rm -f /var/run/elasticsearch/elasticsearch.pid
		service elasticsearch start
		tail -f /var/log/elasticsearch/elasticsearch.log

An even more optimal way to distribute Elasticsearch, Logstash and Kibana across several nodes or hosts would be to extend the ELK image in the same way as outlined above to create separate images for Elasticsearch, Logstash, and Kibana, and run these three trimmed images on the appropriate nodes or hosts (e.g. Elasticsearch on several hosts, Logstash on a dedicated host, and Kibana on another dedicated host).

In this case, you would also need to make sure that the configuration file for Logstash's Elasticsearch output plugin (`/etc/logstash/conf.d/30-output.conf`) points to a host belonging to the Elasticsearch cluster rather than `localhost` (which is the default in the ELK image, since Elasticsearch and Logstash run together), e.g.:

	output {
	  elasticsearch { hosts => ["elk-master.example.com"] }
	}

## Security considerations <a name="security-considerations"></a>

As it stands this image is meant for local test use, and as such hasn't been secured: access to the ELK services is not restricted, and default authentication server certificates (`logstash-*.crt`) and private keys (`logstash-*.key`) for the Logstash input plugins are bundled with the image.

To harden this image, at the very least you would want to:

- Restrict the access to the ELK services to authorised hosts/networks only, as described in e.g. [Elasticsearch Scripting and Security](http://www.elasticsearch.org/blog/scripting-security/) and [Elastic Security: Deploying Logstash, ElasticSearch, Kibana "securely" on the Internet](http://blog.eslimasec.com/2014/05/elastic-security-deploying-logstash.html).
- Password-protect the access to Kibana and Elasticsearch (see [SSL And Password Protection for Kibana](http://technosophos.com/2014/03/19/ssl-password-protection-for-kibana.html)).
- Generate a new self-signed authentication certificate for the Logstash input plugins (e.g. `cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -subj "/CN=elk/" -days 3650 -newkey rsa:2048 -keyout private/logstash-beats.key -out certs/logstash-beats.crt` for a 10-year certificate issued to a server with hostname `elk` for the Beats input plugin) or (better) get a proper certificate from a commercial provider (known as a certificate authority), and keep the private key private.

## References <a name="references"></a>

- [How To Install Elasticsearch, Logstash, and Kibana 4 on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-4-on-ubuntu-14-04)
- [The Docker Book](http://www.dockerbook.com/)
- [The Logstash Book](http://www.logstashbook.com/)
- [Elastic's reference documentation](https://www.elastic.co/guide/index.html):
	- [Elasticsearch Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
	- [Logstash Reference](https://www.elastic.co/guide/en/logstash/current/index.html)
	- [Kibana Reference](https://www.elastic.co/guide/en/kibana/current/index.html)
	- [Filebeat Reference](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)

## About <a name="about"></a>

Written by [Sébastien Pujadas](http://pujadas.net), released under the [Apache 2 license](http://www.apache.org/licenses/LICENSE-2.0).
