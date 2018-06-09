---
layout: post
title: Introducing Custom iOS App Analytics
date: '2017-07-13 21:52:42'
---

TL;DR: Check out my new iOS framework for using CloudKit to track app analytics: [TPHCloudAnalytics](https://github.com/taphouseio/TPHCloudAnalytics).

In my current reworking of Scorebook I wanted to get rid of Cocoapods if I could. I don’t have anything specific against it, but I wanted some more rapid development of my own framework code. So I moved the private pods I had to git submodules. This left me with only the Fabric and Crashlytics pods leftover.

While Fabric’s dashboard is quite impressive, they’ve added almost too much for my needs lately. I just want something simple to tell me how many sessions I’m getting with some basic device info, and maybe some ability to track custom events. Plus, removing Fabric meant that I could remove all closed source frameworks from Scorebook.

I had the idea a little while back to build analytics on top of the CloudKit public database. Today I had the opportunity to make it. The source is all up on [Github here](https://github.com/taphouseio/TPHCloudAnalytics).

It’s fairly rough right now, only sending data to CloudKit. In the long-term I would like to add an iOS or Mac app that can ingest the data from CloudKit and present a nice dashboard. But for now this gets you to the place of recording your data.

I’d love any feedback you have to give.