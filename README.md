# Elasticsearch, Logstash, Kibana (ELK) Docker image

This Docker image provides a convenient centralised log server and log management web interface, by packaging [Elasticsearch](http://www.elasticsearch.org/), [Logstash](http://logstash.net/), and [Kibana](http://www.elasticsearch.org/overview/kibana/), collectively known as ELK.
 
## Installation

Install [Docker](https://docker.com/), either using a native package (Linux) or wrapped in a virtual machine (Windows, Mac OS X – e.g. using [Boot2Docker](http://boot2docker.io/) or [Vagrant](https://www.vagrantup.com/)).

To pull this image from the Docker registry, where it has been built automatically from the source files in this Git repository:

	$ docker pull sebp/elk

**Note** – To build this image from the source files, clone the Git repository and run `sudo docker build -t <repository-name> .` from the root directory (i.e. the directory that contains `Dockerfile`).  

## Usage

Run the container from the image with the following command:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk sebp/elk

This command publishes the following ports, which are needed for proper operation of the ELK stack: 5601 (Kibana web interface), 9200 (Elasticsearch), and 5000 (Logstash server, receives logs from logstash forwarders – see next section). The figure below shows how the pieces fit together.

	                                           +--------------------------------------------+
	                                           |                  ELK server (Docker image) |
	+----------------------+                   |                                            |
	|                      |       +------------> port 5601 - Kibana web interface          |
	|  Admin workstation   +-------+           |                                            |
	|                      |       +------------> port 9200 - Elasticsearch JSON interface  |
	+----------------------+                   |                                            |
	                                           |                                            |
	+----------------------+                   |                                            |
	| Server               |                   |                                            |
	| +------------------+ |                   |                                            |
	| |logstash forwarder+----------------------> port 5000 - Logstash server               |
	| +------------------+ |                   |                                            |
	+----------------------+                   +--------------------------------------------+


Access Kibana's web interface by browsing to `http://<your-host>:5601`, where `<your-host>` is the hostname or IP address of the host Docker is running on (see note), e.g. `localhost` if running a native version of Docker, or the IP address of the virtual machine if running a wrapped version of Docker (see note).

**Note** – To configure and/or find out the IP address of a VM-hosted Docker installation, see [https://docs.docker.com/installation/windows/](https://docs.docker.com/installation/windows/) (Windows) and [https://docs.docker.com/installation/mac/](https://docs.docker.com/installation/mac/) (Mac OS X) for guidance if using Boot2Docker. If you're using Vagrant, you'll need to set up port forwarding (see [https://docs.vagrantup.com/v2/networking/forwarded_ports.html](https://docs.vagrantup.com/v2/networking/forwarded_ports.html).

Click the home icon to view the dashboard. The dashboard will remain empty until some logs have actually been forwarded to Logstash (see next section).

## Forwarding logs

Forwarding logs from a host relies on a Logstash forwarder agent collecting logs (e.g. from log files, from the syslog daemon) and sending them to our instance of Logstash.

Install [Logstash forwarder](https://github.com/elasticsearch/logstash-forwarder) on the host you want to collect and forward logs from (see the References section below for links to detailed instructions).

Here is a sample configuration file for Logstash forwarder, that forwards syslog and authentication logs, as well as nginx logs. 

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

In the sample configuration file, make sure that you:

- replace `elk` in `elk:5000` with the hostname or IP address of the ELK-serving host,
- copy the `logstash-forwarder.crt` file (which contains the Logstash server's certificate) from the ELK image to `/etc/pki/tls/certs/logstash-forwarder.crt`.  

**Note** – The ELK image includes configuration items (`/etc/logstash/conf.d/11-nginx.conf` and `/opt/logstash/patterns/nginx`) to parse nginx access logs, as forwarded by the Logstash forwarder instance above.  

### Linking a Docker container to the ELK container 

If you want to forward logs from a local Docker container to the ELK container, then you need to link the two containers.

First of all, give the ELK container a name (e.g. `elk`) using the `--name` option:  

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk sebp/elk

Then start the log emitting container with the `--link` option:

	$ sudo docker run -p 80:80 -it --link elk:elk sebp/nginx

From the perspective of the log emitting container, the ELK container is now known as `elk`, which is the hostname to be used in the `logstash-forwarder` configuration file.  

## Security considerations

This image is meant for local use, and as such hasn't been secured: access to the ELK services is not restricted, and a default authentication server certificate (`logstash-forwarder.crt`) and private key (`logstash-forwarder.key`) are bundled with the image.

To harden this image, at the very least you would want to:

- Restrict the access to the ELK services to authorised hosts/networks only, as described in e.g. [Elasticsearch Scripting and Security](http://www.elasticsearch.org/blog/scripting-security/) and [Elastic Security: Deploying Logstash, ElasticSearch, Kibana "securely" on the Internet ](http://blog.eslimasec.com/2014/05/elastic-security-deploying-logstash.html).
- Password-protect the access to Kibana and Elasticsearch (see [SSL And Password Protection for Kibana](http://technosophos.com/2014/03/19/ssl-password-protection-for-kibana.html).
- Generate a new self-signed authentication certificate for the Logstash server (`cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt`) or (better) get a proper certificate, and keep the private key private.

## References

- [How To Use Logstash and Kibana To Centralize Logs On CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-logs-on-centos-7)
- [Elasticsearch, Fluentd, and Kibana: Open Source Log Search and Visualization](https://www.digitalocean.com/community/tutorials/elasticsearch-fluentd-and-kibana-open-source-log-search-and-visualization)
- [The Docker Book](http://www.dockerbook.com/)
- [The Logstash Book](www.logstashbook.com)