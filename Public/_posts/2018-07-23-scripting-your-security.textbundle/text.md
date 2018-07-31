---
filename: 2018-07-23-scripting-your-security
layout: post
title: Securing an nginx Container with letsencrypt
date: '2018-07-23 17:55:19'
---

One of the things I wanted to automate with my new website was deployment, including fetching SSL certificates and installing them in nginx. I came into this project knowing nothing about shell scripts and Docker. Now I know a _little_about each. With the web going increasingly https I knew I had to jump this hurdle to be production ready.

Thankfully I found a [blog post](http://chrisstump.online/2016/05/05/lets-encrypt-docker-rails) that helped me get started. All I had to do was make some adaptations to my setup. While that post is very much talking about his environment I wanted this post to generalize for others (be it a static site or one on a separate container like mine).

My sample project uses a Vapor web server, but you can sub out anything you wish for that. [Here’s the sample on GitHub](https://github.com/jsorge/vapor-hello-world)

We start with a Dockerfile that will build up our nginx container:

```bash
# build from the official Nginx image
```

This file had to be modified a bit from the referenced blog post above. The script he used was updated to a new name and support current [letsencrypt](https://letsencrypt.org) standards. I also wanted to inject the domain in from the outside. So the `build_domain` argument comes in to this script and creates an environment variable out of it. Pretty handy!

The last line here calls a script which preps everything for the SSL procedure:

```bash
#!/usr/bin/env bash
```

The gist of what’s going on here is that we are setting up SSL. This script can be invoked in either a dev environment or a production one (that variable is configured in the docker-compose file below). This is handy for local development where a self-signed cert will do. For production it will go through the whole process of phoning the letsencrypt service and getting real certificates.

We then assemble our server config file that gets copied into the container. Here’s that template:

```bash
server {
```

I’m no nginx expert and largely this is copied from the other blog post. You’ll hopefully notice the environment variables throughout the file (like `$DOMAIN`). They get substituted out in our Dockerfile.

Another easily overlooked part of this file is the line `proxy_pass http://web:8080`. This host is used by Docker as a token. The `web` host will be setup as a service in our Docker compose file.

Speaking of the compose file, here it is:

```bash
version: "3.3"
```

The `web`service sets up our web server, and then the `nginx` service configures our container by running the Dockerfile. We expose the ports needed by nginx and also install the volumes.

If you wanted to simplify and use a static site, you could pass the whole directory of your site as a volume and put it in the nginx server’s root directory. I’ve not done that myself, but it seems logical for static sites. In that case you wouldn’t need the `web` service at all, and in the server config file you’d probably use `localhost ` for the proxy pass value. 

I hope this has been helpful, and taken some of the pain out of getting SSL up and running on your website. I’m happy to help with any questions you might have, via [email or Twitter](https://jsorge.net/about).