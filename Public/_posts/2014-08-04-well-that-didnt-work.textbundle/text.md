---
layout: post
title: Well That Didn't Work
date: '2014-08-04 04:19:52'
---

When I left yesterday I had the crazy idea of writing my Bing Image fetcher in Swift. The main reason was that decoding the JSON sent back from a server requires lots of trial-and-error, and the playground seemed like the best place for that.

In reality I think I need to do some more investing into Swift to learn its idiocyncracies that I want to right now. I'm motivated to work on a product and not as much figure out a new language. I've run into 2 issues:

1. Swift playgrounds don't seem to work well with network activity. I am trying to use the `NSURLSession` `dataTaskWithRequest:completionHandler:` method that takes a closure for a callback. In my testing I have never gotten the closure to be called in the sandbox. Not sure if this is a bug or not.

2. I grabbed some sample JSON and started trying to decode it, but the playground kept crashing on me. I'm also having to do lots of crazy casting since Swift Dictionaries aren't what is getting decoded with the `NSJSONSerialization` class and I have to cast back to `NSDictionary`.

It's not that I'm thinking Swift isn't advanced enough for what I'm trying to do, rather I would rather get this part of the app working and move on. Swift is more of a curiosity to me right now since it's not done yet, continuously changing, and not production ready at the moment.

This feels like a good time to plug the Swift Workshop that's being held as part of [CocoaConf in Seattle this October](http://cocoaconf.com/seattle-2014/home). I'm going and can't wait. After that I should be more ready to tackle Swift.