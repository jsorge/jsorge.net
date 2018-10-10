---
filename: 2018-10-09-the-wonderful-responder-chain
layout: post
title: The Wonderful Cocoa (Touch) Responder Chain
shortDescription: 
date: '2018-10-09 20:43:30'
---

Ask an experienced Cocoa developer about the responder chain and I bet they’ll sing its praises. However, if you ask an iOS developer about it you might be greeted with a confused shrug. I myself have had sparing opportunities to use it. So let’s ask a first question: what’s it for?

My take of things is that the responder chain is a good way for disparate objects to talk to one another. Think of a view deep in the hierarchy wanting to send some message to a superview. My particular use case has a table view cell needing to talk with the view controller containing the table view itself. There are a few ways we can do this without the responder chain. A non-exhaustive list includes: callback closures passed down (very in-style for modern iOS development), using a delegate, or an old-fashioned `Notification` (née `NSNotification`).

So we know the problem we’re trying to solve. How does the responder chain work? The main method we’ll be working with is on `UIApplication`.

```swift
func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool
```

Before we dive in, there’s [another post worth your reading on the Black Pixel blog from a few years ago][1]. I’ll be rehashing some of their post here, and hopefully adding some helpful details as well.

Let’s start with a code sample so we can be on the same page. You should be able to paste this into a brand new project and have it work (assuming Xcode 10 and Swift 4.2 here).

```swift
extension Selector {
    static let trigger = #selector(ViewController.somethingHappenedForAResponder(sender:forEvent:))
}

final class HandledEvent: UIEvent {
    let title: String

    init(title: String) {
        self.title = title
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Press Me", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc
    func somethingHappenedForAResponder(sender: AnyObject?, forEvent event: HandledEvent) {
        print("triggered event named \(event.title)")
    }

    @objc
    func buttonPressed() {
        print("button pressed")
        let event = HandledEvent(title: "Foo")
        UIApplication.shared.sendAction(.trigger, to: nil, from: self, for: event)
    }
}
```

Most of this code is boilerplate to add the button and handle its touch. The chain of events is button press -\> responder chain -\> view controller triggered. Let’s look at it piece by piece.

1. The button is tapped, calling `buttonPressed()` on our view controller
2. The view controller creates a new instance of `HandledEvent` and calls the responder chain. This is triggered by sending `nil` in the `to` parameter of our `UIApplication.sendAction(_:,to:,from:,for:)` method. The responder hierarchy will be walked to see if anyone responds to the given selector.
3. iOS will walk each member of the responder chain and calls `responds(to:)` on each member. Both `UIView` and `UIViewController` inherit from `UIResponder` so they play in that chain.
4. When the system finds a responder for the selector, it will be called with that method.

While our example here is as trivial as it gets, hopefully you can see some of the hidden power. We could have a table view (like they have in the Black Pixel post I linked to above), and each cell has a button. Tapping a cell’s button sends the action to the system, which will dispatch to the view controller and handle that action.

There are 2 components from the Black Pixel example that I copied because of how good they are:
1. I LOVE the `Selector` extension. This makes it super easy to reason about at the call site, and tucks the implementation bits away so that my caller need not know about what the selector is. Imagine having multiple of these call sites with the same `#selector...` syntax. This is so much nicer.
2. I really like using a `UIEvent` subclass to send the data I need. In hindsight this is an obvious thing (because the `event` argument has to be of that subclass) but at first it didn’t occur to me.

So now we have a good way of sending data using an event from one place to another, without having to pipe anything crazy through the system. 🎉

While this technique is the right tool for a certain kind of job, it also has some sharp edges to be aware of. Here’s what I’ve noticed:
* The selector being used must have the `@objc` decoration. This is to expose the method to the Objective-C runtime where all the “magic” happens.
* The selector on our view controller could have 0, 1, or 2 parameters. However they must be ordered properly: `AnyObject`, then `UIEvent`. If you try to go with a single parameter of just a `UIEvent` you will get a runtime (funtime) crash.
* You must have an argument in the `from` parameter in the `sendEvent` call. Otherwise the selector you pass will never be called
* However, you can mess with the `trigger` definition. You could omit the arguments entirely and it will still work. While `Selector` is a type, I believe it’s just a compile-time thing. At runtime it compiles down to a string which is passed into the Objective-C `performSelector:` method call. This blows my mind.

While Swift is taking the iOS developer world by storm, I think we shouldn’t neglect the tools we have at our disposal. The responder chain is an incredibly useful API to know how to use. If you’ve been in a situation where you are passing callbacks down a chain, or delegating every table view cell for a callback I highly suggest giving this technique a try. You might just be amazed at how much code you can delete.

[1]:	https://medium.com/bpxl-craft/event-delivery-on-ios-part-3-14463fba84b4