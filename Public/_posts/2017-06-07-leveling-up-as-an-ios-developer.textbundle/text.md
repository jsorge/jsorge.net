---
layout: post
title: Leveling Up as an iOS Developer
date: '2017-06-07 05:08:09'
---

I posted to [my microblog](http://jsorge.micro.blog/2017/05/10/i-feel-like.html) recently that I feel like I’ve been leveling up as an iOS developer. The main way has been diving into programatic layout as opposed to using Interface Builder. This has been really insightful to me and I have come to love writing my views this way. But mostly I’m learning that I can do it.

You can too.

I remember hearing about the devs who didn’t use IB and thought to myself, “that sounds like so much work.” Bear in mind that those prior folks were likely using manual layout to set frames and relied on a lot of math to get things done. Recent improvements to the Auto Layout system (especially layout anchors) make writing UI code incredibly  straightforward.

For instance, to pin a view to the edges of its superview (something I have to do often) all I need is this:

```swift
firstView.addSubview(secondView)
secondView.leadingAnchor.constraint(equalTo:firstView.leadingAnchor).isActive = true
secondView.trailingAnchor.constraint(equalTo:firstView.trailingAnchor).isActive = true
```

And that’s really it. If you’re used to thinking about views in the relationship style of Auto Layout you too can easily start writing your views in code. There are lots of benefits: no more optional properties for `@IBOutlet`s, you can keep you layouts contained to a single file instead of a source file and a layout file, and you can use things like [`UILayoutGuide`](https://medium.com/@karthikkeyan/uilayoutguide-auto-layout-helper-view-ecfb1af5e09d) to line up views without resorting to dummy `UIView` instances.

But my main idea has really nothing to do with ditching Interface Builder. There have been lots of blog posts about that and I’m not sure I could add much to that discussion.

My main idea is that mountains can be intimidating. You look up at someone who is at a higher point than you and wonder if you have what it takes to get up there with them. Start at base camp and get going. 

You’ll try new things. You’ll fail. Get back up and keep climbing. 

Months or years into your journey you’ll look down and remember where you started. Take stock of things in that moment. Praise the Lord for getting you where you are. It’s a big deal!

From there it’s important to stay humble and keep going. Try to help someone climb alongside you. Reach out to the people who are where you want to be and ask questions (you may be shocked at the generous people you meet along the way). We weren’t meant to live solitarily – find your community.

I’m taking this verse completely out of context but Romans 5:3-4 (NIV) says:

> Not only so, but we also glory in our sufferings, because we know that suffering produces perseverance; perseverance, character; and character, hope.

Perseverance builds character. We level up when we keep going in the face of difficulty.