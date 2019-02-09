---
microblog: false
title: Sys. Admin Miscellany
layout: post
date: 2014-03-26T20:06:21Z
staticpage: false
---

The transition of the site seemed to go smoothly over the weekend. The problem was it went a bit *too* smoothly. Let me preface this short tale with a disclaimer that I'm not a system administrator by trade. I've not dabbled here before.

I'm using Hover to manage the domain registration. With Tumblr I pointed the DNS to their servers and it just worked. This time around I did things differently (and the wrong way in hindsight).

I switched the DNS from Hover to Digital Ocean, and pointed my nameservers at Hover to Digital Ocean's nameservers. This seemed to work quickly and efficiently.

Today I discovered that I wasn't receiving email to my jsorge.net domain (also managed by Hover). Turns out I did it wrong. DNS needs to be managed by Hover for my email to continue working. So I undid my DNS at Digital Ocean, pointed the nameservers back to Hover and changed the DNS A records to my actual Digital Ocean server. Problem solved.

So the moral of the story for me is to not go making things "more efficent" when I don't know exactly what I'm doing. The kicker is that I could have missed some pretty important emails over the last few days since Sunday night. Hopefully the downtime won't come back to haunt me too badly.