One of the things I wanted to automate with my new website was deployment, including fetching SSL certificates and installing them in nginx. I came into this project knowing nothing about shell scripts and Docker. Now I know a _little_about each. With the web going increasingly https I knew I had to jump this hurdle to be production ready.

Thankfully I found a [blog post](http://chrisstump.online/2016/05/05/lets-encrypt-docker-rails) that helped me get started. All I had to do was make some adaptations to my setup. While that post is very much talking about his environment I wanted this post to generalize for others (be it a static site or one on a separate container like mine).

My sample project uses a Vapor web server, but you can sub out anything you wish for that. [Here’s the sample on GitHub](https://github.com/jsorge/vapor-hello-world)

We start with a Dockerfile that will build up our nginx container:

```docker
# build from the official Nginx image
FROM nginx

# install essential Linux packages
RUN apt-get update -qq && apt-get -y install apache2-utils curl

# sets the environment domain variable for use in other files
ARG build_domain
ENV DOMAIN $build_domain

# where we store everything SSL-related
ENV SSL_ROOT /var/www/ssl
 
# where Nginx looks for SSL files
ENV SSL_CERT_HOME $SSL_ROOT/certs/live
 
# copy over the script that is run by the container
COPY ./nginx/web_cmd.sh /tmp/
RUN ["chmod", "+x", "/tmp/web_cmd.sh"]

# establish where Nginx should look for files
ENV WEB_ROOT /home/hello-world/Public/

# Set our working directory inside the image
WORKDIR $WEB_ROOT

# copy over static assets
COPY Public /home/hello-world/Public

# copy our Nginx config template
COPY ./nginx/server.conf /tmp/docker_example.nginx

# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN envsubst '$DOMAIN:$WEB_ROOT:$SSL_ROOT:$SSL_CERT_HOME' < /tmp/docker_example.nginx > /etc/nginx/conf.d/default.conf

# Define the script we want run once the container boots
# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "/tmp/web_cmd.sh" ]
```

This file had to be modified a bit from the referenced blog post above. The script he used was updated to a new name and support current [letsencrypt](https://letsencrypt.org) standards. I also wanted to inject the domain in from the outside. So the `build_domain` argument comes in to this script and creates an environment variable out of it. Pretty handy!

The last line here calls a script which preps everything for the SSL procedure:

```bash
#!/usr/bin/env bash

# initialize the dehydrated environment
setup_letsencrypt() {

  # create the directory that will serve ACME challenges
  mkdir -p .well-known/acme-challenge
  chmod -R 755 .well-known

  # See https://github.com/lukas2511/dehydrated/blob/master/docs/domains_txt.md
  echo "$DOMAIN www.$DOMAIN" > domains.txt

  # See https://github.com/lukas2511/dehydrated/blob/master/docs/wellknown.md
  echo "WELLKNOWN=\"$WEB_ROOT.well-known/acme-challenge\"" >> config

  # fetch stable version of dehydrated
  curl "https://raw.githubusercontent.com/lukas2511/dehydrated/v0.6.2/dehydrated" > dehydrated
  chmod 755 dehydrated
}

# creates self-signed SSL files
# these files are used in development and get production up and running so dehydrated can do its work
create_pems() {
  openssl req \
      -x509 \
      -nodes \
      -newkey rsa:1024 \
      -keyout privkey.pem \
      -out $SSL_CERT_HOME/fullchain.pem \
      -days 3650 \
      -sha256 \
      -config <(cat <<EOF
[ req ]
prompt = no
distinguished_name = subject
x509_extensions    = x509_ext
 
[ subject ]
commonName = $DOMAIN
 
[ x509_ext ]
subjectAltName = @alternate_names
 
[ alternate_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF
)
 
  openssl dhparam -out dhparam.pem 2048
  chmod 600 *.pem
}

# if we have not already done so initialize Docker volume to hold SSL files
if [ ! -d "$SSL_CERT_HOME" ]; then
  mkdir -p $SSL_CERT_HOME # _HOME
  chmod 755 $SSL_ROOT
  chmod -R 700 $SSL_ROOT/certs
  cd $SSL_CERT_HOME
  create_pems
  cd $SSL_ROOT
  setup_letsencrypt
fi

# if we are configured to run SSL with a real certificate authority run dehydrated to retrieve/renew SSL certs
if [ "$CA_SSL" = "true" ]; then

  # Nginx must be running for challenges to proceed
  # run in daemon mode so our script can continue
  nginx

  # accept the terms of letsencrypt/dehydrated
  ./dehydrated --register --accept-terms

  # retrieve/renew SSL certs
  ./dehydrated --cron

  # copy the fresh certs to where Nginx expects to find them
  cp $SSL_ROOT/certs/$DOMAIN/fullchain.pem $SSL_ROOT/certs/$DOMAIN/privkey.pem $SSL_CERT_HOME

  # pull Nginx out of daemon mode
  nginx -s stop
fi

# start Nginx in foreground so Docker container doesn't exit
nginx -g "daemon off;"
```

The gist of what’s going on here is that we are setting up SSL. This script can be invoked in either a dev environment or a production one (that variable is configured in the docker-compose file below). This is handy for local development where a self-signed cert will do. For production it will go through the whole process of phoning the letsencrypt service and getting real certificates.

We then assemble our server config file that gets copied into the container. Here’s that template:

```nginx
server {
	server_name $DOMAIN;
	listen 443 ssl;

	root $WEB_ROOT;

	# configure SSL
	ssl_certificate $SSL_CERT_HOME/fullchain.pem;
	ssl_certificate_key $SSL_CERT_HOME/privkey.pem;
    ssl_dhparam $SSL_CERT_HOME/dhparam.pem;

	try_files $uri @proxy;

	location @proxy {
		proxy_pass http://web:8080;
		proxy_pass_header Server;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass_header Server;
		proxy_connect_timeout 3s;
		proxy_read_timeout 10s;
	}
}

server {
  # many clients will send unencrypted requests
  listen 80;

  # accept unencrypted ACME challenge requests
  location ^~ /.well-known/acme-challenge {
    alias $SSL_ROOT/.well-known/acme-challenge/;
  }

  # force insecure requests through SSL
  location / {
    return 301 https://$host$request_uri;
  }
}
```

I’m no nginx expert and largely this is copied from the other blog post. You’ll hopefully notice the environment variables throughout the file (like `$DOMAIN`). They get substituted out in our Dockerfile.

Another easily overlooked part of this file is the line `proxy_pass http://web:8080`. This host is used by Docker as a token. The `web` host will be setup as a service in our Docker compose file.

Speaking of the compose file, here it is:

```yaml
version: "3.3"
services:
  web:
    image: jsorge/hello-world
    volumes:
      - ./Public:/app/Public
  nginx:
    build:
      context: .
      dockerfile: ./nginx/Dockerfile-nginx
      args:
        build_domain: hello.world
    environment:
      CA_SSL: "true"
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Public:/home/hello-world/Public
      - ./nginx/ssl:/var/www/ssl
      - ./nginx/logs:/var/log/nginx
    depends_on:
      - web

```

The `web`service sets up our web server, and then the `nginx` service configures our container by running the Dockerfile. We expose the ports needed by nginx and also install the volumes.

If you wanted to simplify and use a static site, you could pass the whole directory of your site as a volume and put it in the nginx server’s root directory. I’ve not done that myself, but it seems logical for static sites. In that case you wouldn’t need the `web` service at all, and in the server config file you’d probably use `localhost ` for the proxy pass value. 

I hope this has been helpful, and taken some of the pain out of getting SSL up and running on your website. I’m happy to help with any questions you might have, via [email or Twitter](https://jsorge.net/about).
