---
layout: post
title: UITableView Prototypes & Custom Cell Heights
date: '2014-09-03 03:44:35'
---

I'm working on an app and building the UI with Storyboards on Xcode 6 and I've ran into an interesting problem. I have a `UITableView` with 2 defined prototypes, and I wanted them to each have their own heights. Seemed simple enough, since you can define row heights within the storyobard directly.

But when I ran, the row heights were all wrong. They reverted back to standard 44-point height.

What I had to do was change the row height in the Table View itself on the storyboard, because that's the number that really matters. At runtime it looks as if the custom heights are ignored completely in the storyboard (even if you override `tableView:estimatedHeightForRowAtIndexPath:`).

This leaves me with only 1 single row-height in my table. Not horrendous, since I can work around it and make the layout work and look good. But not ideal. I was hoping to have section 0 be more like a header (since I also couldn't get the `tableView:viewForHeaderInSection:` method to work properly, either).

Is this a bug in UIKit? Xcode? Something that should be reported at all?