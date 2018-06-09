---
layout: post
title: Swift Array Mapping Question
date: '2015-12-01 19:01:51'
---

I have an array that contains objects, and those objects have arrays that I want to collapse into a single array.

Basically, I want to be able to remove 2 for-in loops and replace them with a line of code (if I can while maintaining readability).

How would you write this? See [https://gist.github.com/jsorge/140d42e710b5f39f59ad](https://gist.github.com/jsorge/140d42e710b5f39f59ad) for the code.

<script src="https://gist.github.com/jsorge/140d42e710b5f39f59ad.js"></script>

**Update**: Not 2 minutes after a [@brentsimmons](https://twitter.com/brentsimmons/) retweet, Andy Matuschak gave me the answer:
<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/jsorge">@jsorge</a> <a href="https://twitter.com/brentsimmons">@brentsimmons</a> company.flatMap { $0.workers.filter { $0.isCool } }</p>&mdash; Andy Matuschak (@andy_matuschak) <a href="https://twitter.com/andy_matuschak/status/671767439139430400">December 1, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>