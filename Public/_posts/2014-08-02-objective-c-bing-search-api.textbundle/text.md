---
microblog: false
title: Objective-C Bing Search API
layout: post
date: 2014-08-02T09:31:10Z
staticpage: false
---

I'm working on a new app that will need to search a web API for images. Google Image search's API was deprecated long ago and it's not clear if they have anything to replace it. So I'm going with Bing.

The documentation is really bad. Like, really bad. So I'm foraging on my own for right now since there isn't a Cocoapod to handle this. I'm doing image search only, taking one term and wanting to convert the response into a bunch of NSObjects to display the results. Once the results have come back the user can tap on an image to assign it to their data.

Shouldn't be too hard, right?

Although now part of me wants to tackle this in Swift.