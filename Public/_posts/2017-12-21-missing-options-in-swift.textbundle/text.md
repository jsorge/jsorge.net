---
layout: post
title: Missing Options in Swift
date: '2017-12-21 00:18:38'
---

The default behavior of iOS is to not show a notification (like the kind that comes in through your phone’s lock screen or Notification Center) if the app is in the foreground. I’m working on a ticket for the Lyft app to show or suppress notifications that come in while the app is in the foreground. iOS 10 introduced a whole new `UserNotification` framework that lets us do just that! 

The delegate of our notification center will get a call aptly named `userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)`. Since we always have to call the completion handler – and that parameter defines the type of presentation we want – we can now control the notification’s display.

In Objective-C the options are so:

* UNNotificationPresentationOptionsNone (kind of)
* UNNotificationPresentationOptionsAlert
* UNNotificationPresentationOptionsBadge
* UNNotificationPresentationOptionsSound

But in Swift, `UNNotificationPresentationOptionsNone` is not available. In fact, you can only really see the docs for this option [at this page](https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptionnone). It’s listed as a Global Variable, and not a member of an enumeration. There’s [a separate page for the `UNNotificationPresentationOptions` enumeration](https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions?language=objc).

So I fired up a sample project and made a method that returned None from Objective-C and bridged that over to Swift. Of course it works, and the raw value is 0. So the options for my ticket are either add Objective-C back into the project (all our code is Swift) just to bring this over, or make a local variable set to a raw value of 0. The latter is likely what I’ll end up doing.

I’ve filed [radar 36166279](http://openradar.appspot.com/radar?id=4981130382016512) to address this.

**Update 12/21/2017**

After posting this, [Jake Carter](https://twitter.com/JakeCarter) replied to me on Twitter with an idea:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Have you tried setting a no options value via []? See the ‘noOptions’ example in the Using an Option Set Type section of <a href="https://t.co/UPct7ImcyM">https://t.co/UPct7ImcyM</a></p>&mdash; Jake Carter (@JakeCarter) <a href="https://twitter.com/JakeCarter/status/943725387900583936?ref_src=twsrc%5Etfw">December 21, 2017</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

When I got in to the office this morning I gave it a go and it worked! I’ve used the `[]` syntax before so I’m a little disappointed that I didn’t remember it. I plugged that into my sample app and its `rawValue` turned out to be 0. So now I don’t have to choose between two bad options.

I think what tripped me up was seeing that the Objective-C version was an enumeration coupled with me not seeing that the Swift structure conforms to `OptionSet`. If I had slowed down for just a couple of minutes then I might have noticed.

I think I’m going to leave the radar open, though. I will probably amend it with these findings and make it more of a documentation issue rather than needing to add a new option to the `UNNotificationPresentationOptions` type. Thanks Jake!