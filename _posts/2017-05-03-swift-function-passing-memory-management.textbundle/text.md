---
layout: post
title: Swift Function Passing & Memory Management
date: '2017-05-03 15:33:41'
---

I’ve started using a pattern where I use a struct that has a series of optional closures on it to serve as a way to hook into default implementations of things like data source and delegate calls. We have a fairly complex way of presenting data in our collection views that requires a lot of boilerplate, but specific areas of our app needs to add behavior to fit its requirements.

The problem that I’m running into now is that I want to assign these closures to functions on my object instead of having a ton of inline closures. I really like this approach because it allows me to keep things well organized. But there’s a problem in my memory graph.

When I pass these functions into the closures, I’m capturing a strong reference to `self`. When using a closure syntax I could use a capture list to take either `[weak self]` or `[unowned self]` and be fine (in fact, replacing the function references with closures doing just that makes the problem go away).

Here’s a gist replicating the issue:
<script src="https://gist.github.com/jsorge/fe51cbbc2450366fc43e895e1a091bdc.js"></script>

If you copy the file into a playground and run it you will see `deinit` called on the VC but not on the data source or the frame. If you uncomment the closure on lines 46-48, they will all have `deinit` called as you would expect.

Is there a way to capture an `[unowned self]` when passing a function by reference like this?

**Update**: I wound up going with a solution that uses a closure for the hook instead of the function reference – passing in `unowned self` inside the capture list. Inside that closure I call the method. It doesn't look quite as nice as what I wanted to do, but gets the job done. Here's what that would look like with the example:

```swift
hooks.numberOfSectionsIn = { [unowned self] (section) -> Int? in
    return self.numberOfSectionsIn(section)
}
```