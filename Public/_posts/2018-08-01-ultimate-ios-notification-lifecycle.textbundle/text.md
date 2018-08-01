---
filename: 2018-08-01-ultimate-ios-notification-lifecycle
layout: post
title: The Ultimate Guide to iOS Notification Lifecycles
shortdescription: Come along on a journey of exploration as we look at the life of notifications on iOS.
date: '2018-08-01 10:06:38'
---

I work on the notifications team at Lyft for my day job. One of the things that comes up frequently is the question of how can we trigger our code from a push notification (or even, “what is a push notification”). I’ve had these chats enough that it seemed relevant to put together what I hope to be the definitive answer. I hope it’s useful to you.

Here we go.

### What is a user notification?

Let’s start small. A user notification is a way for app developers to let their user know that something in the app warrants their attention. Users can be notified in any combination of three different ways: an alert (most commonly a banner that drops down from the top of the screen), a sound, and/or a badge.

Apps must ask users for permission to show these notifications before anything can be displayed. Oftentimes apps will show their own custom view asking for permission before displaying the system dialog. This is because an app can only prompt their users once for display of notifications. After that, the user must go to the app’s preference screen in the system Settings.app.

### How can user notifications be triggered?

Notifications can be scheduled as a local notification, or delivered via push. Both types of notifications can do the same things, appear exactly the same to the user, and as of iOS 10, Apple unified the notification system under the `UNUserNotificationCenter` suite of APIs. This makes handling of notifications the same.

### What is a push notification?

A push notification is a notification that comes in remotely. It may or may not display any content (ones that do not display content are referred to as silent pushes). It is important to note that apps _do not have to ask the user’s permission to deliver push notifications._ Silent pushes do not require user permission.

You must register your app with the system in order to send a push. This is done with `UIApplication.shared.registerForRemoteNotifications()`. You’ll be called back with the result of this by implementing `application(UIApplication, didRegisterForRemoteNotificationsWithDeviceToken: Data)` for success, and `application(UIApplication, didFailToRegisterForRemoteNotificationsWithError: Error)` for failure. When the registration succeeds, you’ll get a device token that needs to be registered with your server that you’ll use to send a push.

### When does my code run via push?

This is going to get complicated. The short answer is: it depends. But you didn’t come here for short answers, so let’s dig in. We’ll start by looking at an actual notification payload. I’ll put in the stuff we need, but you can find [the full payload content reference here][1].

```js
{
  "aps": {
	"alert": {
	  "title": "Our fancy notification",
	  "body": "It is for teaching purposes only."
	},
	"badge": 13,
	"sound": "fancy-ding",
	"content-available": 1,
	"category": "CUSTOM_MESSAGE",
	"thread-id": "demo_chat",
	"mutable-content": 1
  }
}
```

If you were to send this payload to a device, the user would see an alert with the title being the `aps.alert.title` value, the app icon would badge with the `aps.badge` value, and the sound would be the `aps.sound` value (assuming all the permissions were granted by the user).

You might want to send a notification that wakes up your app to fetch some content in the background, and a silent push is perfect for that task. This can be accomplished by setting the `aps. content-available` field like the example. When the system receives this notification it may wake up your app. Wait, _may_ wake up? Why won’t it _always_ wake up the app?

This brings us to the uncomfortable reality: the payload contents as well as the app state determine when your code is activated. Let’s look at a chart:

<table>
<colgroup>
<col style="text-align:left;"/>
<col style="text-align:left;"/>
<col style="text-align:left;"/>
</colgroup>

<thead>
<tr>
	<th style="text-align:left;">App State</th>
	<th style="text-align:left;">Payload</th>
	<th style="text-align:left;">Result</th>
</tr>
</thead>

<tbody>
<tr>
	<td style="text-align:left;">Backgrounded</td>
	<td style="text-align:left;">aps.content-available = 1</td>
	<td style="text-align:left;"><code>application(_:didReceiveRemoteNotification:fetchCompletionHandler:)</code></td>
</tr>
<tr>
	<td style="text-align:left;">Running</td>
	<td style="text-align:left;">aps.content-available = 1</td>
	<td style="text-align:left;"><code>application(_:didReceiveRemoteNotification:fetchCompletionHandler:)</code></td>
</tr>
<tr>
	<td style="text-align:left;">Killed</td>
	<td style="text-align:left;">aps.content-available = 1</td>
	<td style="text-align:left;">Nothing</td>
</tr>
<tr>
	<td style="text-align:left;">Running</td>
	<td style="text-align:left;">aps.content-available = 0</td>
	<td style="text-align:left;">Nothing</td>
</tr>
<tr>
	<td style="text-align:left;">Backgrounded</td>
	<td style="text-align:left;">aps.content-available = 0</td>
	<td style="text-align:left;">Nothing</td>
</tr>
</tbody>
</table>

So, if your app is running or has been backgrounded, you’ll be called. But if the user has killed your app, nothing happens. Bummer! The next question you may ask is if there is a way for your code to run every time a notification comes in. Indeed there is.

Apple gives us two different extension points that let us run code when notifications arrive: [UNNotificationServiceExtension][2] and [UNNotificationContentExtension][3].

#### Notification Service Extension

With the service extension, the intention is that you are going to mutate the content of the extension before it is presented to the user. The typical use cases are for things like decrypting an end-to-end encrypted message, or attaching a photo to a notification. 

There are 2 main requirements that your notification must meet in order for this extension to fire: Your payload must contain both `aps.alert.title` and `aps.alert.body` values, and `aps.mutable-content` must be set to 1. The payload we have above satisfies both of those requirements and would trigger our app’s service extension if it had one.

It’s important to note that you cannot trigger a service extension with a silent push. The intention is for the extension to mutate a notification’s content, and silent pushes have no content.

<table>
<colgroup>
<col style="text-align:left;"/>
<col style="text-align:left;"/>
</colgroup>

<thead>
<tr>
	<th style="text-align:left;">Payload</th>
	<th style="text-align:left;">Result</th>
</tr>
</thead>

<tbody>
<tr>
	<td style="text-align:left;"><code>aps.mutable-content</code> = 1 &amp;&amp; <code>aps.title</code> != nil &amp;&amp; <code>aps.body</code> != nil</td>
	<td style="text-align:left;">Extension Fires</td>
</tr>
<tr>
	<td style="text-align:left;">Anything else</td>
	<td style="text-align:left;">Nothing</td>
</tr>
</tbody>
</table>

### Notification Content Extension

The other extension type allows us to paint a custom view on top of a notification, instead of relying on the system to render the notification. Users get to see this custom view when they force press or long press a notification (or in Notification Center, they can swipe left on a notification and tap “View”). 

When you include one of these with your app, the extension’s Info.plist file declares an array called `UNNotificationExtensionCategory`. Each of these categories maps to a notification’s `aps.category` value. To go back to our sample notification above, our app would have to register a content extension for the `CUSTOM_MESSAGE` category.

<table>
<colgroup>
<col style="text-align:left;"/>
<col style="text-align:left;"/>
</colgroup>

<thead>
<tr>
	<th style="text-align:left;">Payload</th>
	<th style="text-align:left;">Result</th>
</tr>
</thead>

<tbody>
<tr>
	<td style="text-align:left;">Extension&#8217;s UNNotificationExtensionCategory contains aps.category</td>
	<td style="text-align:left;">Extension Fires</td>
</tr>
<tr>
	<td style="text-align:left;">Anything else</td>
	<td style="text-align:left;">Nothing</td>
</tr>
</tbody>
</table>

### One more thing

There’s one last bit that I want to cover: The [UNUserNotificationCenterDelegate][4] protocol. A conformer will get called in two main cases: when your app is in the foreground and will present a notification, and when a notification is tapped on.

When the user taps on one of your notifications, the app will fire up and come to the foreground. It’s a good idea to register the notification center delegate at startup so you’ll get the `userNotificationCenter(_:didReceive:withCompletionHandler:)` call. This lets you properly handle the notification, otherwise your app will just come to the foreground and that’s it.

### Wrap-up

We’ve come a long ways, looking over the kinds of notifications we can have (interactive and silent), the different transport mechanisms for them (local and push), and how all these ways can interact with our code.

[1]:	https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW5
[2]:	https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension
[3]:	https://developer.apple.com/documentation/usernotificationsui/unnotificationcontentextension
[4]:	https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate#