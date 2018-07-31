---
filename: 2018-07-31-ultimate-ios-push-lifecycle
layout: post
title: The Ultimate Guide to iOS Push Lifecycles
date: '2018-07-31 10:06:38'
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

You might want to send a notification that wakes up your app to fetch some content in the background, and a silent push is perfect for that task. This can be accomplished by setting the `aps. content-available` field to 1. More on this later on.

### When does my code run via push trigger?

This is going to get complicated. 