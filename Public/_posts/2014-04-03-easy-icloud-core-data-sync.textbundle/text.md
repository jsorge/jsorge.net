---
microblog: false
title: '"Easy" iCloud Core Data Sync'
layout: post
date: 2014-04-02T20:49:33Z
staticpage: false
---

I'm writing a small app that will allow me to save drafts of posts to the site, and I'm trying some things that I've learned lately. 

The first is some of the best practices explained by [Paul Goracke at the Seattle Xcoders meeting in February](http://corporationunknown.com/blog/2014/02/16/core-data-potpourri/). He  gave a cool example of sublassing `NSManagedObjectContext` and having that object setup the Core Data stack.

Doing things this way means that instead of having my App Delegate load the persistent store and setup its coordinator, I wrap that all in my Context's factory method to create the object. I really like how this is working out so far.

The other piece that I'm putting in place is iCloud sync. First off, I want to emphasize how simple my model is. I have one entity that will be synced, which represents a draft. That said, it's surprising to me how easy it was to setup the sync. [Much of how I figured this out is from the great objc.io issue on sync](http://www.objc.io/issue-10/icloud-core-data.html).

First, the app needs to have the proper entitlements, which is dead simple in Xcode 5. A trip to the target's Capabilities tab and flipping the iCloud switch to "On" is all you need.

Then, add an option to the `addPersistentStoreWithType:configuration:URL:options:error:` method. There's a string constant called `NSPersistentStoreUbiquitousContentNameKey`, which is a key in the options dictionary and you just pass in the value of what you want the persistent store to be called.

Finally, you need to account for changes that get made to the local store and to the remote stores. These are monitored via `NSNotificationCenter`. I'm also adding a notification of my own that my view controller listens for, so that it knows when to update the UI when changes come in. Simple!

I haven't begun accounting for any edge cases yet, but the basics seem to be pretty straightforward to implement. Much simpler than I was expecting.

If you're interested to see how I've done it, you can view the [ManagedObjectContext classes](https://github.com/jsorge/CoreDataHelpers), or the [entire project](https://github.com/jsorge/GhostPost) on Github. I'd also love to hear how I could make this better.