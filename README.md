# Elasticsearch, Logstash, Kibana (ELK) Docker image

This Docker image provides a convenient centralised log server and log management web interface, by packaging [Elasticsearch](http://www.elasticsearch.org/) (version 1.4.4), [Logstash](http://logstash.net/) (version 1.4.2), and [Kibana](http://www.elasticsearch.org/overview/kibana/) (version 4.0.1), collectively known as ELK.
 
## Installation

Install [Docker](https://docker.com/), either using a native package (Linux) or wrapped in a virtual machine (Windows, Mac OS X – e.g. using [Boot2Docker](http://boot2docker.io/) or [Vagrant](https://www.vagrantup.com/)).

To pull this image from the Docker registry, where it has been built automatically from the source files in the source Git repository, open a shell prompt and enter:

	$ sudo docker pull sebp/elk

**Note** – If you want to build the image yourself, see the *Building the image* section below.

## Usage

Run the container from the image with the following command:

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk sebp/elk

This command publishes the following ports, which are needed for proper operation of the ELK stack:

- 5601 (Kibana web interface).
- 9200 (Elasticsearch)
- 5000 (Logstash server, receives logs from logstash forwarders – see next section).
 
The figure below shows how the pieces fit together.

	-                                +--------------------------------------------+
	                                 |                  ELK server (Docker image) |
	+----------------------+         |                                            |
	|                      |    +-----> port 5601 - Kibana web interface          |
	|  Admin workstation   +----+    |                                            |
	|                      |    +-----> port 9200 - Elasticsearch JSON interface  |
	+----------------------+         |                                            |
	                                 |                                            |
	+----------------------+         |                                            |
	| Server               |         |                                            |
	| +------------------+ |         |                                            |
	| |logstash forwarder+------------> port 5000 - Logstash server               |
	| +------------------+ |         |                                            |
	+----------------------+         +--------------------------------------------+

Access Kibana's web interface by browsing to `http://<your-host>:5601`, where `<your-host>` is the hostname or IP address of the host Docker is running on (see note), e.g. `localhost` if running a local native version of Docker, or the IP address of the virtual machine if running a VM-hosted version of Docker (see note).

**Note** – To configure and/or find out the IP address of a VM-hosted Docker installation, see [https://docs.docker.com/installation/windows/](https://docs.docker.com/installation/windows/) (Windows) and [https://docs.docker.com/installation/mac/](https://docs.docker.com/installation/mac/) (Mac OS X) for guidance if using Boot2Docker. If you're using [Vagrant](https://www.vagrantup.com/), you'll need to set up port forwarding (see [https://docs.vagrantup.com/v2/networking/forwarded_ports.html](https://docs.vagrantup.com/v2/networking/forwarded_ports.html).

### Running the image using Docker Compose or Fig

If you're using [Docker Compose](http://fig.sh) (formerly known as Fig) to manage your Docker services (and if not you really should as it will make your life much easier!), then you can create an entry for the ELK Docker image by adding the following lines to your `docker-compose.yml` file (or `fig.yml` if using Fig):

	elk:
	  image: sebp/elk
	  ports:
	    - "5601:5601"
	    - "9200:9200"
	    - "5000:5000"

You can then start the ELK container like this:

	$ sudo docker-compose up elk 

or (with Fig):

	$ sudo fig up elk 

As from Kibana version 4.0.0, you won't be able to see anything (not even an empty dashboard) until something has been logged (see the next sub-section on how to test your set-up by creating a dummy log entry, and the next section on how to forward logs from regular applications).

### Creating a dummy log entry

If you haven't got any logs yet and want to manually create a dummy log entry for test purposes (for instance to see the dashboard), first start the container as usual (`sudo docker run ...` or `docker-compose up ...`).

In another terminal window, find out the name of the container running ELK, which is displayed in the last column of the output of the `sudo docker ps` command.

	$ sudo docker ps
	CONTAINER ID        IMAGE                  ...   NAMES
	86aea21cab85        elkdocker_elk:latest   ...   elkdocker_elk_1

Open a shell prompt in the container and type (replacing `<container-name>` with the name of the container, e.g. `elkdocker_elk_1` in the example above):

	$ sudo docker exec -it <container-name> /bin/bash 

**Note** - If you're running a pre-1.4 version of Docker (before the `exec` command was introduced) then:

- Run the container interactively:

	- With the regular `docker` command use `sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk sebp/elk /bin/bash` – note the extra `/bin/bash` at the end compared to the usual command line
	- With Docker Compose or Fig use `sudo docker-compose run --service-ports elk /bin/bash` (substituting `fig` for `docker-compose` if you're using Fig).

- At the container's shell prompt, type to `start.sh&` to start Elasticsearch, Logstash and Kibana in the background, and wait for everything to be up and running (wait for `{"@timestamp":…,"message":"Listening on 0.0.0.0:5601",…}`)

Now enter:

	# /opt/logstash/bin/logstash -e 'input { stdin { } } output { elasticsearch { host => localhost } }'

And then type some dummy text followed by Enter to create a log entry:

	this is a dummy entry

**Note** - You can create as many entries as you want. Use `^C` to go back to the bash prompt.

After a few seconds if you browse to *http://<your-host>:9200/_search?pretty* (e.g. [http://localhost:9200/_search?pretty](http://localhost:9200/_search?pretty) for a local native instance of Docker) you'll see that Elasticsearch has indexed the entry:

	{
	  …
	  "hits" : {
	    …
	    "hits" : [ {
	      "_index" : "logstash-…",
	      "_type" : "logs",
		  …
	      "_source":{"message":"this is a dummy entry","@version":"1","@timestamp":…}
	    } ]
	  }
	}

You can now browse to Kibana's web interface at *http://<your-host>:5601* (e.g. [http://localhost:5601](http://localhost:5601) for a local native instance of Docker).

From the drop-down "Time-field name" field, select `@timestamp`, then click on "Create", and you're good to go. 

## Forwarding logs

Forwarding logs from a host relies on a Logstash forwarder agent collecting logs (e.g. from log files, from the syslog daemon) and sending them to our instance of Logstash.

Install [Logstash forwarder](https://github.com/elasticsearch/logstash-forwarder) on the host you want to collect and forward logs from (see the References section below for links to detailed instructions).

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

In the sample configuration file, make sure that you:

- Replace `elk` in `elk:5000` with the hostname or IP address of the ELK-serving host.
- Copy the `logstash-forwarder.crt` file (which contains the Logstash server's certificate) from the ELK image to `/etc/pki/tls/certs/logstash-forwarder.crt`.  

**Note** – The ELK image includes configuration items (`/etc/logstash/conf.d/11-nginx.conf` and `/opt/logstash/patterns/nginx`) to parse nginx access logs, as forwarded by the Logstash forwarder instance above.  

### Linking a Docker container to the ELK container 

If you want to forward logs from a local Docker container to the ELK container, then you need to link the two containers.

First of all, give the ELK container a name (e.g. `elk`) using the `--name` option:  

	$ sudo docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk sebp/elk

Then start the log-emitting container with the `--link` option:

	$ sudo docker run -p 80:80 -it --link elk:elk sebp/nginx

From the perspective of the log emitting container, the ELK container is now known as `elk`, which is the hostname to be used in the `logstash-forwarder` configuration file.

With Docker Compose (or Fig) here's what example entries for a (locally built log-generating) nginx container and an ELK container could look like in the `docker-compose.yml` (or `fig.yml`) file. 

	nginx:
	  build: nginx
	  ports:
	    - "80:80"
	  links:
	    - elk
	
	elk:
	  image: sebp/elk
	  ports:
	    - "5601:5601"
	    - "9200:9200"
	    - "5000:5000"
  

## Building the image

To build the Docker image from the source files, first clone the [Git repository](https://github.com/spujadas/elk-docker), go to the root of the cloned directory (i.e. the directory that contains `Dockerfile`), and:

- If you're using the vanilla `docker` command then run `sudo docker build . -t <repository-name>`, where `<repository-name>` is the repository name to be applied to the image, which you can then use to run the image with the `docker run` command.

- If you're using Docker Compose then run `sudo docker-compose build elk`, which uses the `docker-compose.yml` file to build the image. You can then run the built image with `sudo docker-compose up`.
 
- If you're using Fig, then rename `docker-compose.yml` to `fig.yml` and run `sudo fig build elk`. Start the resulting image with `sudo fig up`.

## Extending the image

To extend the image, you can either fork the source Git repository and hack away, or – more in the spirit of the Docker philosophy – use the image as a base image and build on it, adding files (e.g. configuration files to process logs sent by log-producing applications) and overwriting files (e.g. configuration files, certificate and private key files) as required.

To create a new image based on this base image, you want your `Dockerfile` to include:

	FROM sebp/elk

followed by instructions to extend the image (see Docker's [Dockerfile Reference page](https://docs.docker.com/reference/builder/) for more information).

## Security considerations

As it stands this image is meant for local test use, and as such hasn't been secured: access to the ELK services is not restricted, and a default authentication server certificate (`logstash-forwarder.crt`) and private key (`logstash-forwarder.key`) are bundled with the image.

To harden this image, at the very least you would want to:

- Restrict the access to the ELK services to authorised hosts/networks only, as described in e.g. [Elasticsearch Scripting and Security](http://www.elasticsearch.org/blog/scripting-security/) and [Elastic Security: Deploying Logstash, ElasticSearch, Kibana "securely" on the Internet ](http://blog.eslimasec.com/2014/05/elastic-security-deploying-logstash.html).
- Password-protect the access to Kibana and Elasticsearch (see [SSL And Password Protection for Kibana](http://technosophos.com/2014/03/19/ssl-password-protection-for-kibana.html).
- Generate a new self-signed authentication certificate for the Logstash server (`cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt` for a 10-year certificate) or (better) get a proper certificate from a commercial provider (known as a certificate authority), and keep the private key private.

## References

- [How To Use Logstash and Kibana To Centralize Logs On CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-logs-on-centos-7)
- [Elasticsearch, Fluentd, and Kibana: Open Source Log Search and Visualization](https://www.digitalocean.com/community/tutorials/elasticsearch-fluentd-and-kibana-open-source-log-search-and-visualization)
- [The Docker Book](http://www.dockerbook.com/)
- [The Logstash Book](http://www.logstashbook.com/)