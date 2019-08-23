---
microblog: false
title: Struggling With SwiftUI
layout: post
date: 2019-08-23T04:51:58Z
staticpage: false
shortdescription: Getting going with SwiftUI feels a lot like what getting going with Swift felt like 5 years ago. Or bending my mind to work with reactive programming. I hope you'll bear with me in some rubber ducking.
filename: 2019-08-19-struggling-with-swiftui.textbundle
tags: []
---
SwiftUI was the big thing coming out of WWDC in June. It was the toast of the town and I saw lots of comments about how developers "wanted to rewrite their entire app" using it. Heck, I was one of those voices too. I think it's clear that SwiftUI is the future of writing interfaces for Apple's platforms.

When it came time to start working on Scorebook's iOS 13 update I decided to take a pragmatic approach. After all, my app's users won't care if the UI is SwiftUI or UIKit. They won't care if it's written in Swift or Objective-C, built in code or Interface Builder. They want the app to work, and to work well. How it gets there is my concern as the developer. So instead of doing the fun SwiftUI update I started in on things that they will care about. So I started with Dark Mode.

There are some rough spots on the main screens but when I got to Settings, everything was wrong. "Perfect!", I thought. I wanted an easy way to get started with SwiftUI, and with SwiftUI I get dark mode support for free. I built my Settings screens as static `UITableView` subclasses and there's a bunch of logic that can be factored out and made simpler to handle switch taps as well as the actions like sending a support email or triggering the rating dialog.

Getting the bare form up and running was pretty easy all told. I'm not running Catalina yet so I don't get the live previews. I had to shim the SwiftUI view into my app's tab bar, which I accomplished with a `UIViewController` which embeds a `UIHostingController` that has my `SettingsListView` as its root view. I did this to preserve getting the tab item for the Settings tab from the UIKit object rather than trying to see if the SwiftUI view can provide it. Then came binding my switches to `UserDefaults`, and I started feeling out of my element.

When I started writing this post it got me pouring out many more words than I thought would be triggered, so I'm going to break this up into two parts. The next part I'll go over some concrete places where I've had issues and the answers I arrived at (if I got there, that is – this is all very much a work in progress).
