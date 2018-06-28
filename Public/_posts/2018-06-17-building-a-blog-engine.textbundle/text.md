---
layout: post
title: Building a Blog Engine
date: '2018-06-17 14:40:21'
---

For the last few months I’ve been [thinking about what to do with my blog setup.](https://jsorge.net/2018/04/15/reconsidering-my-blogging-setup/) I experimented a bit with Jekyll but that ended up not really appealing to me. In the consideration of switching platforms I realized I wanted something that would be easy to move (and not be beholden to should the need to move again arise). Markdown text files check that box; but what about images?

How would I move the images I’ve hosted on my own server? Where do they land in the new location? I had no good idea until I stumbled up on [textbundles](http://textbundle.org). Textbundles basically wrap up a markdown file and assets folder inside of a directory. Bundles are a very [familiar concept for anyone on a Mac](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html); we’ve had them since OS X became a thing.

I first decided to figure out how to make this format work in Jekyll. Would it be a hook I need to build? Where would that go in the pipeline and how does it work? Also, [how do I even Ruby](https://learnxinyminutes.com/docs/ruby/)?

All of this started to make my new site feel like a distant goal. Learning a new language and framework was kind of daunting. Not that I’m opposed to such things, but I don’t have a ton of extra time available plus it could easily distract me from my goal.

In the meantime I decided to give Vapor a look again. I’d played with v2 last year when trying to rebuild my company website. It was… ok. But Vapor 3 really clicked for me and I could see while writing it how a blog engine could work. So I figured I’d go for it.

[Meet Maverick.](https://github.com/jsorge/maverick)

As of this writing I’m probably 80% done with the site. In local testing it does exactly what I need it to do on a basic level. Blog post and static page support. Everything served from a textbundle. That’s the easy part.

The hard part now is how to deploy. I’ve got a lot to learn about Docker and TLS. I tried adding TLS to the new Taphouse site and couldn’t get it figured out. But also if I want to make this an easy system for someone else to adapt, how do I do that?

I know that posts should be separated from the engine itself. So the bare repo for new sites should have some script to grab the Maverick app and run it in some container. Since it’s just a self-contained Swift app that _should_ be straightforward enough, right?

All of this consideration kind of has me paralyzed at the moment. I was hoping to punt on deployment a bit until I got [Ulysses](https://ulyssesapp.com) and [Micro.blog](https://micro.blog) support wrapped up but they seem to depend on TLS connections, and that brings me back to getting things deployed.

So that’s where I’m at. I’m super excited about getting Maverick onto my server and running it full time. But getting there means jumping a few more hurdles first.