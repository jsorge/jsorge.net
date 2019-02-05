---
filename: 2019-02-04-uiview-mask-safety-scissors
layout: post
title: On the Sharp Edges of UIView.mask
shortDescription: I lost some hours to figuring out how UIView's mask property works. Hopefully this will save you some time if you come across that property as well.
date: '2019-02-04 19:27:34'
---
I'm working on implementing a new user-facing feature at work, and the designs I've been given call for having a dark gray semi-transparent view overlaying a view, and this semi-transparent view has a rectangle punched out of it. Not having done this kind of thing before I went searching the docs on `CALayer` to see what options are available. I knew that layers could mask other layers so this seemed like the right place to go.

While using a layer-based mask seemed promising initially, I wanted flexibility to move this mask around pretty easily using Auto Layout constraints. I stumbled upon a [really helpful article from Paul Hudson](https://www.hackingwithswift.com/example-code/uikit/how-to-mask-one-uiview-using-another-uiview) outlining the [UIView property called `mask`](https://developer.apple.com/documentation/uikit/uiview/1622557-mask). From the docs, this property is:

> An optional view whose alpha channel is used to mask a view’s content.

That's the entire description we're given. I ran the code from Paul's blog post in a playground and sure enough I was able to mask the view (more on this later). So I adopted it in our app, and I ran it. I looked and there was no mask. In fact, the entire overlay was not visible. Huh? Why would this work in a playground but not the app?

Turns out there are a couple of undocumented gotchas that go along with using a mask, and if you don't know them you could spend a lot of time learning the hard way. I'm hoping this will spare you some lost hours. Here we go.

1. The mask view cannot be part of a view hierarchy. This means no Auto Layout, and no constraint manipulation. It's all frames with this view.
2. The mask cannot be held on to by _anything_ except for the view it's masking. Don't try to store it as a property or you're in for a bag of hurt (as in it won't work at all, and the view it's masking will no longer be visible).

I suppose that if #2 were to be solved it could make #1 possible, but the reality is that if this property is going to have as many usability issues as it does then the documentation needs to be updated to reflect that. If you've been in the Apple developer sphere for very long you've heard the phrase "Radar or GTFO". With that in mind, I submitted [rdar://47809462](rdar://47809462) ([OpenRadar link](http://www.openradar.me/radar?id=6100860425732096)) as I do not want to GTFO 🙂.
