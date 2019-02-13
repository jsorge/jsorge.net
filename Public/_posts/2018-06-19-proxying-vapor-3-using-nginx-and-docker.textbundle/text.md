---
microblog: false
title: Proxying Vapor 3 Using nginx and Docker
layout: post
date: 2018-06-19T09:00:00Z
staticpage: false
---

Vapor is a framework for running server side code, all built in Swift. There’s a great post by [bygri about how to build a Vapor app using Docker.](https://bygri.github.io/2018/05/14/developing-deploying-vapor-docker.html) If any of what I’ve just said is confusing, I highly recommend reading that post before getting started here.

During my building of a couple of Vapor apps, I’ve found getting the sites running while hitting `localhost:8080` to be really easy. The hard part is putting that site behind a domain locally and even more, getting it deployed to a server. So I’m going to put a huge disclaimer here: I’m no expert in nginx or Docker. I’ve been able to piece things together using web searches and a lot of conversation in the Vapor Discord room. There’s a great channel for Docker specifically, where I’ve been hugely helped by @bygri. He’s good people.

This post’s goal is purely to show how I got my Vapor app - which worked in development - deployed to production and successfully proxied by nginx. There will be a few extra bits I learned along the way as well (just to sweeten the deal for you).

My initial thought process was this: 

1. Everything for my web app lives inside of the git repository.
2. I have a script to run for local development
3. When it’s time to deploy, I clone the repo to my server, and run a script to boot it all up there.

Turns out I was a bit mistaken. If you read through the post I linked at the top, you’ll notice that he has separate Dockerfiles for development and production. I skipped over that part, much to my initial peril (so don’t do that).

What I did was create a repository on the [Docker Hub](https://hub.docker.com) which would hold a named, built image. That image is built with the following Dockerfile:

```docker
# Build image
FROM swift:4.1 as builder
RUN apt-get -qq update && apt-get -q -y install \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so /build/lib
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
  tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/
COPY Resources/ ./Resources/
EXPOSE 8080
ENTRYPOINT ./Run serve -e prod -b 0.0.0.0
```

If you have discerning eyes you’ll notice that this Dockerfile is almost exactly the same as the one in the post [ I referenced above](https://bygri.github.io/2018/05/14/developing-deploying-vapor-docker.html) (go read it and come back if you didn’t earlier). That’s because I copied it from him 😊. The one addition I had to make was `COPY Resources/ ./Resources`. What this does is copies the Resources directory from my local drive and into the Docker image. 

I was initially skeptical that I needed the `EXPOSE` directive since nginx would proxy over there by default, but I’ve confirmed that it’s not exposed on my server and this will make for good documentation, so 🤷‍♂️.

I built that image using `docker build -t jsorge/taphouse.io`. Then I can push the image using `docker push jsorge/taphouse.io`. These 2 commands will build the image and tag it locally, then push it up to Docker Hub. I highly suggest scripting this stuff (I’m becoming partial to Makefiles to get it all done).

Now let’s flip our environment to the production server. I don’t need much to bring in the Vapor app since it’s already built and hosted. I just need to reference it and mount the Public folder.

But then comes the fun part. I’ll catch you on the flipside of the compose file:

```docker
version: "3.3"
services:
  web:
	image: jsorge/taphouse.io
	volumes:
	  - ./Public:/app/Public
  nginx:
	image: nginx:alpine
	restart: always
	ports:
	  - 80:80
	  - 443:443
	volumes:
	  - ./Public:/home/taphouse/Public
	  - ./nginx/server.conf:/etc/nginx/conf.d/default.conf
	  - ./nginx/logs:/var/log/nginx
	depends_on:
	  - web
```

Ok, so what’s going on here? We’re grabbing the `nginx` image from alpine (a trusted provider of nginx). I’m honestly not sure what the `restart` command does but it showed up on my DuckDuckGo results of examples. But the rest I understand. 

`ports`:
I’m exposing ports 80 and 443 to get http and https traffic listened to (the syntax for ports is \<external\>:\<container-internal\>). I could pick other internal ports to listen to and update my nginx configs appropriately but didn’t feel like rocking the boat too much. I plan on adding TLS support via letsencrypt but that’s a problem for another day.

`volumes`:
I’m sure people familiar with Docker won’t need this explained (or any of this compose file really) but this part blows my mind a bit. The volumes directive basically puts a link from the local machine to inside the container. The link could be a file or a folder; that part doesn’t matter. So to get the root of my site working in nginx, I mount the Public folder that exists locally on my machine into the container at the specified path. The syntax for this is \<local-path\>:\<container-path\>.

I also created the path of nginx/logs on my server, and mounted it as the log directory in the container. This allows me to have the logs from the container persisted to my server volume and easily read them as they come in. This is super cool!

[`depends_on`](https://docs.docker.com/compose/compose-file/#depends_on):
This one is pretty cool. It establishes the dependency chain between your containers and starts them up in the proper order to satisfy them. In this case, nginx depends on my Vapor app (called web). 

The nginx configuration file is the last link in the chain to get us going. This is what mine looks like:

```nginx
server {
	server_name taphouse.io;
	listen 80 default_server;

	root /home/taphouse/Public/;

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
```

I got this by finding the suggested configuration for [Vapor 2](https://docs.vapor.codes/2.0/deploy/nginx/). Curiously this page hasn’t made its way to the Vapor 3 docs but I’m guessing that has something to do with them wanting you to deploy on Vapor Cloud. I’m removing my tinfoil hat now.

As far as nginx configuration files go, this one looks pretty standard. I don’t know the exact ins and outs of what’s going on but the point of note is here: `proxy_pass http://web:8080;`. Remember how I said earlier that Docker Compose provides its own networking? Well it turns out I can use my Vapor container name as the host and it will resolve everything inside the container network. Super cool!

From here I got these files on the server and ran my `make server` command (which aliases to `docker-compose -f docker-compose-prod.yml up --build -d`) and tried hitting http://taphouse.io. It worked! 🤯

The next thing on my list is to get [acme.sh](#) working so that TLS is up and running, and I can disable port 80. That’s my current holdup, but when I get that done I’ll be sure to write that up as well.

If I made any grievous errors or you have general feedback, I’d love to hear it. I’m still very green when it comes to Docker, nginx, and server admin stuff in general.