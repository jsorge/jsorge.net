---
microblog: false
title: Reverting SwiftPM for Tools
layout: post
date: 2019-07-25T00:41:57Z
staticpage: false
shortdescription: I gave SwiftPM a good try to serve my tooling needs, but it ended up falling down.
filename: 2019-07-23-reverting-swiftpm-for-tools.textbundle
tags: []
---
For the last few months I've been using [Swift Package Manager](https://github.com/apple/swift-package-manager) to manage my tooling dependencies for iOS projects. It's a technique that I [learned about from Orta Therox](https://artsy.github.io/blog/2019/01/05/its-time-to-use-spm/) and I adopted it in [Scorebook](https://taphouse.io/scorebook) and even [made an app template that used it too](https://jsorge.net/2019/05/26/my-ios-xcode-project-template). The advantages were great, namely that I didn't have to manage any version scripts or vendor tools directories. It just worked.

But over the last couple of weeks things started to fall apart a little bit. I downloaded Xcode 11 after releasing my new Scorebook update so that I could start digging in to all the cool stuff iOS 13 had to offer. I also checked my tools to see if they had new versions available (I'm using 2 different tools at the moment – [Xcodegen](https://github.com/yonaskolb/XcodeGen) and [swift-sh](https://github.com/mxcl/swift-sh)). I went to update them and that's when I got my first error: `dependency graph is unresolvable`.

I did some digging and what seems to have happened is that my tools have conflicting dependencies. Bummer!

I had some options at this point: 1) figure out what the conflicts were and solve them by forking and opening pull requests on one or both of Xcodegen and swift-sh. 2) Create separate tools modules for each tool. 3) Roll back using SwiftPM for my tooling needs and build scripts to maintain each tool.

#1 would have taken a long time to resolve and didn't seem super worth my while. #2 would have been _slightly_ more tolerable but maintaining that directory structure didn't seem super worthwhile, and would have likely necessitated scripts for each tool anyway. #3 felt like the right choice in the end, and that's what I went with.

The upshot of going the way that I did is that I can always ensure that I'm using a binary version of each tool, and if I come across one that's not written in Swift I can add that to my project with the same amount of effort as a Swift-based one. Using SwiftPM for tooling like this was always kind of a hack. It was meant to manage dependencies of your project and to easily bring in libraries to your codebase.

I'd love for it to work again someday, but for now I'm mostly glad to have gotten over this hurdle so I can move on to more interesting problems like adding Dark Mode to Scorebook.

I pushed the change I made to my iOS template, and if there's a better way to write the bash scripts I'm all ears (I'm sure there is, since I'm a bash noob still). [Check out the updated code here](https://github.com/jsorge/ios-project-template/commit/616296f8835fb357ad2fcfbb702ec6d5d7748747).
