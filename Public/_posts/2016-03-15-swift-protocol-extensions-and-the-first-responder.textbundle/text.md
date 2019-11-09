I tried to do something clever yesterday, and it didn't work. I don't think it's too clever (hopefully, but if I am please let me know).

In Swift, I've declared a protocol and it contains a method. I then extend the protocol and give that method an default implementation. Because of how Swift works, I can call it on any object that conforms to the protocol and it will work. This is really awesome stuff.

However, if I want my declaring object to be a first responder to that method, it doesn't work. It seems to be because of how the Objective-C runtime and Swift interact. Any object that conforms to the protocol still returns `NO` when asked if it responds to a selector.

I've created a gist (embedded below) that shows my problem. Line 24 is where things break down.

<script src="https://gist.github.com/jsorge/e5237717ecf1b18cab66.js"></script>

What I want is for a view controller of mine to respond `YES` when it's asked about a method on my protocol and then perform the action as implemented in the extension. Is there a way to do this?

I've filed rdar://25167402 to hopefully resolve the issue. If there is a way for me to get this done, I'd love to hear it too.
