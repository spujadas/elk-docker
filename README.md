# Elasticsearch, Logstash, Kibana (ELK) Docker image

[![](https://images.microbadger.com/badges/image/sebp/elk.svg)](https://microbadger.com/images/sebp/elk "Get your own image badge on microbadger.com") [![Documentation Status](https://readthedocs.org/projects/elk-docker/badge/?version=latest)](http://elk-docker.readthedocs.io/?badge=latest)

This Docker image provides a convenient centralised log server and log management web interface, by packaging Elasticsearch, Logstash, and Kibana, collectively known as ELK.

### Documentation

See the [ELK Docker image documentation web page](http://elk-docker.readthedocs.io/) for complete instructions on how to use this image.

### Docker Hub

This image is hosted on Docker Hub at [https://hub.docker.com/r/sebp/elk/](https://hub.docker.com/r/sebp/elk/).

The following tags are available:

- `latest`, `8.3.3`: ELK 8.3.3.

- `oss-8.3.3` (ELK OSS 8.3.3), `8.3.2` (8.3.2), `oss-8.3.2` (OSS 8.3.2), `8.3.1` (8.3.1), `oss-8.3.1` (OSS 8.3.1), `8.3.0` (8.3.0), `oss-8.3.0` (OSS 8.3.0), `8.2.3` (8.2.3), `oss-8.2.3` (OSS 8.2.3), `8.2.2` (8.2.2), `oss-8.2.2` (OSS 8.2.2), `8.2.1` (8.2.1), `oss-8.2.1` (OSS 8.2.1), `8.2.0` (8.2.0), `oss-8.2.0` (OSS 8.2.0), `8.1.3` (8.1.3), `oss-8.1.3` (OSS 8.1.3), `8.1.2` (8.1.2), `oss-8.1.2` (OSS 8.1.2), `8.1.1` (8.1.1), `oss-8.1.1` (OSS 8.1.1), `8.1.0` (8.1.0), `oss-8.1.0` (OSS 8.1.0), `8.0.1` (8.0.1), `oss-8.0.1` (OSS 8.0.1), `8.0.0` (8.0.0), `oss-8.0.0` (OSS 8.0.0).

- `7.17.1` (ELK 7.17.5), `oss-7.17.1` (OSS 7.17.5), `7.17.1` (7.17.1), `oss-7.17.1` (OSS 7.17.1), `7.17.0` (7.17.0), `oss-7.17.0` (OSS 7.17.0), `7.16.3` (7.16.3), `oss-7.16.3` (OSS 7.16.3), `7.16.2` (7.16.2), `oss-7.16.2` (OSS 7.16.2), `7.16.1` (7.16.1), `oss-7.16.1` (OSS 7.16.1), `7.16.0` (7.16.0), `oss-7.16.0` (OSS 7.16.0), `7.15.2` (7.15.2), `oss-7.15.2` (OSS 7.15.2), `7.15.1` (7.15.1), `oss-7.15.1` (OSS 7.15.1), `7.15.0` (7.15.0), `oss-7.15.0` (OSS 7.15.0), `7.14.2` (7.14.2), `oss-7.14.2` (OSS 7.14.2), `7.14.1` (7.14.1), `oss-7.14.1` (OSS 7.14.1), `7.14.0` (7.14.0), `oss-7.14.0` (OSS 7.14.0), `7.13.4` (7.13.4), `oss-7.13.4` (OSS 7.13.4), `7.13.3` (7.13.3), `oss-7.13.3` (OSS 7.13.3), `7.13.2` (7.13.2), `oss-7.13.2` (OSS 7.13.2), `7.13.1` (7.13.1), `oss-7.13.1` (OSS 7.13.1), `7.13.0` (7.13.0), `oss-7.13.0` (OSS 7.13.0), `7.12.1` (7.12.1), `oss-7.12.1` (OSS 7.12.1), `7.12.0` (7.12.0), `oss-7.12.0` (OSS 7.12.0), `7.11.2` (7.11.2), `oss-7.11.2` (OSS 7.11.2), `7.11.1` (7.11.1), `oss-7.11.1` (OSS 7.11.1), `oss-7.11.0` (OSS 7.11.0), `7.11.0` (7.11.0), `oss-7.10.2` (OSS 7.10.2), `7.10.2` (7.10.2), `oss-7.10.1` (OSS 7.10.1), `7.10.1` (7.10.1), `oss-7.10.0` (OSS 7.10.0), `7.10.0` (7.10.0), `oss-793` (OSS 7.9.3), `793` (7.9.3), `oss-792` (OSS 7.9.2), `792` (7.9.2), `oss-791` (OSS 7.9.1), `791` (7.9.1), `oss-790` (OSS 7.9.0), `790` (7.9.0), `oss-781` (OSS 7.8.1), `781` (7.8.1), `oss-780` (OSS 7.8.0), `780` (7.8.0), `771` (7.7.1), `770` (7.7.0), `762` (7.6.2), `761` (7.6.1), `760` (7.6.0), `752` (7.5.2), `751` (7.5.1), `750` (7.5.0), `742` (7.4.2), `741` (7.4.1), `740` (7.4.0), `732` (7.3.2), `731` (7.3.1), `730` (7.3.0), `721` (7.2.1), `720` (7.2.0), `711` (7.1.1), `710` (7.1.0), `701` (7.0.1), `700` (7.0.0).

- `6.8.22` (ELK 6.8.22), `683` (6.8.3), `681` (ELK 6.8.2), `681` (ELK 6.8.1), `680` (ELK 6.8.0), `672` (ELK 6.7.2), `671` (ELK 6.7.1), `670` (6.7.0), `662` (6.6.2), `661` (6.6.1), `660` (6.6.0), `651` (6.5.1), `650` (6.5.0), `643` (6.4.3), `642` (6.4.2), `641` (6.4.1), `640` (6.4.0), `632` (6.3.2), `631` (6.3.1), `630` (6.3.0), `624` (6.2.4), `623` (6.2.3), `622` (6.2.2), `621` (6.2.1), `620` (6.2.0), `613` (6.1.3), `612` (6.1.2), `611` (6.1.1), `610` (6.1.0), `601` (6.0.1), `600` (6.0.0).

- `5615` (ELK version 5.6.15), `568` (5.6.8), `564` (5.6.4), `563` (5.6.3), `562` (5.6.2), `561` (5.6.1), `560` (5.6.0), `553` (5.5.3), `552` (5.5.2), `551` (5.5.1), `550` (5.5.0), `543` (5.4.3), `542` (5.4.2), `541` (5.4.1), `540` (5.4.0), `532` (5.3.2), `531` (5.3.1), `530` (5.3.0), `522` (5.2.2), `521` (5.2.1), `520` (5.2.0), `512` (5.1.2), `511` (5.1.1), `502` (5.0.2), `es501_l501_k501` (5.0.1), `es500_l500_k500` (5.0.0).

- `es241_l240_k461`: Elasticsearch 2.4.1, Logstash 2.4.0, and Kibana 4.6.1.

- `es240_l240_k460`: Elasticsearch 2.4.0, Logstash 2.4.0, and Kibana 4.6.0.

- `es235_l234_k454`: Elasticsearch 2.3.5, Logstash 2.3.4, and Kibana 4.5.4.

- `es234_l234_k453`: Elasticsearch 2.3.4, Logstash 2.3.4, and Kibana 4.5.3.

- `es234_l234_k452`: Elasticsearch 2.3.4, Logstash 2.3.4, and Kibana 4.5.2.

- `es233_l232_k451`: Elasticsearch 2.3.3, Logstash 2.3.2, and Kibana 4.5.1.

- `es232_l232_k450`: Elasticsearch 2.3.2, Logstash 2.3.2, and Kibana 4.5.0.

- `es231_l231_k450`: Elasticsearch 2.3.1, Logstash 2.3.1, and Kibana 4.5.0.

- `es230_l230_k450`: Elasticsearch 2.3.0, Logstash 2.3.0, and Kibana 4.5.0.

- `es221_l222_k442`: Elasticsearch 2.2.1, Logstash 2.2.2, and Kibana 4.4.2.

- `es220_l222_k441`: Elasticsearch 2.2.0, Logstash 2.2.2, and Kibana 4.4.1.

- `es220_l220_k440`: Elasticsearch 2.2.0, Logstash 2.2.0, and Kibana 4.4.0.

- `E1L1K4`: Elasticsearch 1.7.3, Logstash 1.5.5, and Kibana 4.1.2.

**Note** – See the documentation page for more information on pulling specific combinations of versions of Elasticsearch, Logstash and Kibana.

### About

Written by [Sébastien Pujadas](https://pujadas.net), released under the [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).
