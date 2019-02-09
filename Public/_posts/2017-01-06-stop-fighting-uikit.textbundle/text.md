---
microblog: false
title: Stop Fighting UIKit
layout: post
date: 2017-01-05T19:39:33Z
staticpage: false
---

I’m working on an update to our search screen for work, and getting my hands dirty with `UISearchBar`. I’m placing the search bar in the `titleView` property of our view controller’s `UINavigationItem`, and I’ve run into two different cases that had me fighting with this class and doing things that UIKit probably didn’t intend.  Incidentally, both of these deal with the cancel button that can be presented from a search bar.

First, iPads won’t display the cancel button at all. No idea why but there must be a good reason. A quick web search yielded [a Stack Overflow](http://stackoverflow.com/a/30474662/1861941) answer (of course). I wrapped the search bar in a view and it worked just like I needed. But it felt weird to do so.

The second one, however, had me considering a different approach entirely. When a search term is present in the bar and a user is viewing results, I wanted the cancel button to take us back to the initial state of the screen (which is our Browse screen, displaying categories to shop in).

But that’s not what happened. I was expecting the search bar’s delegate method `searchBarCancelButtonClicked(_:)`[^1] to get called.  When you tap on the cancel button – and the search bar is not the first responder – it just becomes the first responder. You have to then tap on the cancel button for the delegate to get called.

My first thought (ashamedly) was to implement `hitTest(_:, with:)` and figure out if the cancel button (which is a private API) was tapped. This actually worked but involved me writing code like this:

```swift
subviews.filter({ String(describing:$0) == “UINavigationButton” })
```

My idea was to see if the cancel button was being tapped. If so, I’d call the search bar’s delegate cancel method and return nil on the hit test.  This all worked; kind of. There were some other things that I would have to work around. But it all sat wrong with me.

Then I decided to just to forego using the cancel button that comes with `UISearchBar` altogether and put the cancel button as the right bar button item. I get full control this way. I can animate it when I need it to, and I don’t have to worry about its dependence on implementation of UIKit. I like it much better.

The moral of the story is: If you’re fighting UIKit’s behaviors, there may be an easier way to get the job done.

[^1]: I also shuddered when I saw this method as referring to  a “click” action.