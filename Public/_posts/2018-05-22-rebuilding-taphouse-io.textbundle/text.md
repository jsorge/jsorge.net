---
microblog: false
title: Rebuilding taphouse.io
layout: post
date: 2018-05-21T22:11:30Z
staticpage: false
---

A few months ago, when I decided I needed to update JavaScript on my server that ran both my blog and company website, I broke the company site. I wrote it a few years ago using a very early iteration of the [Sails.js](https://sailsjs.com) framework. Fast forward to today and I want to bring it back. I also have been wanting to dabble in server-side Swift. [Enter Vapor](https://vapor.codes).

I got the site up and running in Vapor 3 in a few days (last year I had started doing this in Vapor 2, but 3 was just released so the timing was good). I’m a big fan of what the Vapor team is doing and may yet take on a separate project based on Vapor. But that’s for another day.

Today is about Docker. I want my new company site to be housed in a single git repo (✅), and deployable using [Docker](https://www.docker.com). I want to have the vapor app in a container, and [nginx](https://www.nginx.com) on the front of it in a separate container. I also want to have SSL on the site, managed by [letsencrypt](https://letsencrypt.org). I’m also hoping to have a dev environment and a production environment (all self contained inside this repo).

This is where my holdup is. I’ve never used Docker, [and have been inundating myself](https://mb.jsorge.net/2018/05/19/i-may-have.html) trying to figure it all out.  I want to build this in the open, so I’ll be [microblogging](https://mb.jsorge.net) and regular blogging about my progress – however slow it may be.