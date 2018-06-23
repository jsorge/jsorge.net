---
layout: post
title: AVAsset and ... Touch ID?
date: '2017-04-07 05:33:05'
---

Last week I ran into a crazy bug where trying to create an `AVAsset` instance triggered Touch ID to come up on my screen. Not only was I baffled, I was slightly concerned I wouldn’t be able to figure out what caused this to happen or how to work around it.

I was tasked with adding support for auto-playing video on [zulily’s](http://www.zulily.com) app, a feature that we are adding to our app. I got it working in our dev environment flawlessly, got it merged into our TestFlight branch and deployed to users for testing. The first day, I got reports of Touch ID displaying before playing a video. Authenticating or cancelling made no difference – the video played either way.

I started to dig in. I still couldn’t reproduce on a debug build, only release. So debugging became painful to say the least. A short time later I realized that this is because our debug builds append “.debug” to our product bundle ID so we can run retail and debug side by side. Flipping this back got the issue happening on my device. Bingo!

At the advice of [Tim Ekl](https://twitter.com/timothyekl) I got the prompt on screen and paused in the debugger. This revealed to me that creating the asset triggered `NSURLCredentialStorage`, as well as `CFURLCredentialStorageCopyAllCredentials`. So creating the asset by a URL triggers the keychain to be accessed. 

Diving into our keychain storage indicated that we are storing an item with an access control of `kSecAccessControlUserPresence`. This access control type is defined as “Constraint to access with either Touch ID or passcode. Touch ID does not have to be available or enrolled. Item is still accessible by Touch ID even if fingers are added or removed.” So it seems any access to these kinds of items will bring up Touch ID. Aha!

I’ve been able to narrow it down, now I needed a workaround. Thankfully the thing we are stashing in the keychain is a fairly narrowly used item to store user credentials for our login screen. Most people likely never sign out and back in again. So my solution is to delete the item at startup, just once. If they want to save their login credentials again then we won’t use the access control flag.

To trigger Touch ID, I wrote a method on our manager class to authenticate and then execute a block. This will let us authenticate the user, then retrieve their stored credentials. I was somewhat saved by the fact that we were using this in a fairly trivial manner. I opened up a DTS ticket for the issue and it is currently being looked at by Apple Engineering.

Additionally, I created a sample project to reproduce the issue ([it’s on GitHub here](https://github.com/jsorge/avasset-touch-id-bug)). I also filed [radar 31353719](http://www.openradar.me/31353719) for Apple to investigate further.

I’m curious to see what the solution to the problem is. It likely will be some bug fix in AVFoundation or even Foundation. We shall see. I’m just glad I got the videos working for our project. But it was a fun little bug to hunt down.