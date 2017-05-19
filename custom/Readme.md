#### Steps to install
1. Give the name of s3 bucket in `02-s3-input.conf`.
2. Run ```docker build -t elk-docker-custom .```
3. Run ```sudo docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 5000:5000 -it --name elk elk-docker-custom```

#### Notes:
We can also use the `marathon.json` file to deploy in DCOS - Marathon.