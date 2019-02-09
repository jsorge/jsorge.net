---
microblog: false
title: I ain't afraid o' no Ghost
layout: post
date: 2014-03-24T18:03:23Z
staticpage: false
---

After 6 years on Tumblr, I've decided to make the move to another blogging platform. This new site is being powered by Ghost, the new node.js backed blogging software. I'm hosting it using [Digital Ocean](https://www.digitalocean.com/?refcode=b54194754f24) on an Ubuntu Linux server.

The reasons that I made the move are many but the biggest one is that I want to own the process: On Tumblr I was just responsible for submitting the content that I wanted to post. I could change my theme (which I did) but I couldn't make the CSS responsive. So instead there was a mobile site. I didn't have any database access if I wanted to do something funky, either. It was also more tricky to get my posts out than I would have hoped. Now that I'm on Ghost all my content is stored in an SQLite file, which I can play with all I want.

I was able to bring all my posts from Tumblr over using a [Ghost exporter for Tumblr](https://tumblr-to-ghost.herokuapp.com) and that worked really well for an initial export. The two gotchas are images (which are still linked over to Tumblr) and formatting of posts. I figure I can go back and reformat some of my bigger posts to read better but that's a job for another day.

Ghost comes with a system called themes that allows you to customize how everything looks. The built in theme is Casper. I'm no CSS whiz but I was able to tweak Casper to look good enough for launch. I'm going to continue playing with it and dialing things in further.

I also want to build out the sidebar. Right now the links point to a pretty bare [about page](http://jsorge.net/about) and the Twitter feed for the site. Every post will be sent to that feed. There's also an RSS option at the bottom of every page in the center, which points to [http://jsorge.net/rss](http://jsorge.net/rss).

The other thing that I'll want to build is a simple app to create and send my posts to the site. There's an API on the roadmap for 0.5 which I'm excited to play around with in a week or so after that version launches. I think I'll open-source the code for that app and put it on the app store.

I'm really excited about this new site.